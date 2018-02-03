extern crate chrono;
extern crate getopts;
extern crate kuchiki;
extern crate opengraph;
extern crate read_rust;
extern crate reqwest;
extern crate uuid;

use std::path::Path;
use std::env;

use reqwest::{RedirectPolicy, StatusCode, Url};
use reqwest::header::Location;

use read_rust::feed::{Author, Feed, Item};
use read_rust::error::Error;

use uuid::Uuid;
use kuchiki::traits::TendrilSink;
use chrono::{DateTime, FixedOffset, TimeZone};
use getopts::Options;

fn resolve_url(url: Url) -> Result<Url, Error> {
    let client = reqwest::Client::builder()
        .redirect(RedirectPolicy::none())
        .build()
        .map_err(Error::Reqwest)?;

    // HEAD url, if permanent redirect then follow
    // Else return URL
    let mut request_count = 0;
    let mut url = url;
    while request_count < 10 {
        let response = client.head(url.clone()).send().map_err(Error::Reqwest)?;
        if response.status() == StatusCode::MovedPermanently {
            if let Some(next_url) = response.headers().get::<Location>() {
                let next_url = next_url.to_string();
                url = Url::parse(&next_url).map_err(Error::Url)?;
            }
        }

        // TODO: Add check for success (200)
        request_count += 1;
    }

    Ok(url)
}

struct PostInfo {
    title: String,
    description: String,
    author: Author,
    published_at: Option<DateTime<FixedOffset>>,
}

fn extract_author(doc: &kuchiki::NodeRef) -> Author {
    // Author from meta tag and link
    let author_url = doc.select_first("link[rel='author']")
        .ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("href").map(|href| href.to_owned())
        });

    let author_name = doc.select_first("meta[name='author']")
        .ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("content").map(|content| content.to_owned())
        })
        .or_else(|| {
            doc.select_first("meta[property='author']")
                .ok()
                .and_then(|link| {
                    let attrs = link.attributes.borrow();
                    attrs.get("content").map(|content| content.to_owned())
                })
        })
        .or_else(|| {
            doc.select_first("meta[property='article:author']")
                .ok()
                .and_then(|link| {
                    let attrs = link.attributes.borrow();
                    attrs.get("content").map(|content| content.to_owned())
                })
        });

    Author {
        name: author_name.unwrap_or_else(|| "FIXME".to_owned()),
        url: author_url.unwrap_or_else(|| "FIXME".to_owned()),
    }
}

fn extract_publication_date(doc: &kuchiki::NodeRef) -> Option<DateTime<FixedOffset>> {
    doc.select_first("meta[property='article:published_time']")
        .ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("content").map(|content| content.to_owned())
        })
        .or_else(|| {
            doc.select_first("article time").ok().and_then(|time| {
                let attrs = time.attributes.borrow();
                attrs.get("datetime").map(|content| content.to_owned())
            })
        })
        .and_then(|date| DateTime::parse_from_rfc3339(&date).ok())
}

fn post_info(html: &str) -> Result<PostInfo, Error> {
    let ogobj = opengraph::extract(&mut html.as_bytes()).ok_or(Error::HtmlParseError)?;
    let doc = kuchiki::parse_html().one(html);

    let title = if ogobj.title != "" {
        ogobj.title
    } else {
        doc.select_first("title")
            .map_err(|_err| Error::StringError("Document has no title".to_owned()))?
            .text_contents()
    }.trim().to_owned();

    let description = match ogobj.description {
        Some(desc) => desc,
        None => doc.select_first("meta[name='description']")
            .ok()
            .and_then(|link| {
                let attrs = link.attributes.borrow();
                attrs.get("content").map(|content| content.to_owned())
            })
            .unwrap_or_else(|| "FIXME".to_owned()),
    };

    let author = extract_author(&doc);
    let published_at = extract_publication_date(&doc);

    Ok(PostInfo {
        title,
        description,
        author,
        published_at,
    })
}

fn run(url_to_add: &str, tags: Vec<String>) -> Result<(), Error> {
    let feed_path = Path::new("content/_data/rust/posts.json");
    let mut feed = Feed::load(feed_path)?;

    let url = Url::parse(url_to_add).map_err(Error::Url)?;
    let canonical_url = resolve_url(url)?;

    // Fetch page
    let mut response = reqwest::get(canonical_url.clone()).map_err(Error::Reqwest)?;
    let body = response.text().map_err(Error::Reqwest)?;
    let post_info = post_info(&body)?;

    let item = Item {
        id: Uuid::new_v4(),
        title: post_info.title,
        url: canonical_url.to_string(),
        content_text: post_info.description,
        date_published: post_info
            .published_at
            .unwrap_or_else(|| FixedOffset::east(0).ymd(1970, 1, 1).and_hms(0, 0, 0)),
        author: post_info.author,
        tags: tags,
    };

    feed.add_item(item);

    feed.save(feed_path)
}

fn print_usage(program: &str, opts: Options) {
    let brief = format!("Usage: {} [options] URL", program);
    print!("{}", opts.usage(&brief));
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optmulti("t", "tag", "tag this post with the supplied tag", "TAG");
    opts.optflag("h", "help", "print this help menu");
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => m,
        Err(f) => panic!(f.to_string()),
    };
    if matches.opt_present("h") || matches.free.is_empty() {
        print_usage(&program, opts);
        return;
    }

    run(&matches.free[0], matches.opt_strs("t")).expect("error");
}
