extern crate atom_syndication;
extern crate chrono;
extern crate feedfinder;
extern crate getopts;
extern crate kuchiki;
extern crate opengraph;
extern crate read_rust;
extern crate reqwest;
extern crate rss;
extern crate serde_json;
extern crate uuid;

use std::io::BufReader;
use std::path::Path;
use std::env;

use reqwest::{RedirectPolicy, StatusCode, Url};
use reqwest::header::{ContentType, Location};

use read_rust::feed::*;
use read_rust::error::Error;

use uuid::Uuid;
use kuchiki::traits::TendrilSink;
use chrono::{DateTime, FixedOffset, TimeZone};
use getopts::Options;
use feedfinder::FeedType;
use atom_syndication as atom;

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

fn response_is_ok_and_matches_type(response: &reqwest::Response, feed_type: &FeedType) -> bool {
    if !response.status().is_success() {
        return false;
    }

    if !response.headers().has::<ContentType>() {
        return false;
    }

    let content_type = response
        .headers()
        .get::<ContentType>()
        .map(|ct| ct.to_string().to_lowercase())
        .unwrap(); // Safe due to has check above

    // This doesn't handle a JSON feed discovered through links in the page... for now that's ok
    (*feed_type == FeedType::Json && content_type.contains("json")) || content_type.contains("xml")
}

fn find_feed(html: &str, url: &Url) -> Result<Option<feedfinder::Feed>, Error> {
    let feeds = feedfinder::detect_feeds(url, html)
        .ok()
        .unwrap_or_else(|| vec![]);
    let client = reqwest::Client::new();
    for feed in feeds {
        if let Ok(response) = client.head(feed.url().clone()).send() {
            if response_is_ok_and_matches_type(&response, feed.feed_type()) {
                return Ok(Some(feed));
            }
        }
    }

    Ok(None)
}

fn fetch_and_parse_feed(url: &Url, type_hint: &FeedType) -> Option<Feed> {
    let mut response = reqwest::get(url.clone())
        .map_err(Error::Reqwest)
        .expect("http error");

    if !response.status().is_success() {
        return None;
    }

    let content_type = response
        .headers()
        .get::<ContentType>()
        .map(|ct| ct.to_string().to_lowercase());

    if content_type.is_none() {
        return None;
    }

    let content_type = content_type.unwrap();

    let feed = if content_type.contains("json") || *type_hint == FeedType::Json {
        // TODO: Add a BufReader interface to JsonFeed
        let body = response.text().map_err(Error::Reqwest).expect("read error");
        Feed::Json(
            serde_json::from_str(&body)
                .map_err(Error::JsonError)
                .expect("json error"),
        )
    } else if content_type.contains("atom") || *type_hint == FeedType::Atom {
        Feed::Atom(atom::Feed::read_from(BufReader::new(response)).expect("atom parsing error"))
    } else {
        // Try RSS
        Feed::Rss(rss::Channel::read_from(BufReader::new(response)).expect("rss parsing error"))
    };

    Some(feed)
}

fn post_info_from_feed(post_url: &Url, feed: &Feed) -> PostInfo {
    let post_info = match *feed {
        Feed::Atom(ref feed) => feed.entries()
            .iter()
            .find(|&entry| {
                entry
                    .links()
                    .iter()
                    .any(|link| link.href() == post_url.as_str())
            })
            .map(PostInfo::from),
        Feed::Json(ref feed) => feed.items
            .iter()
            .find(|item| item.url == post_url.as_str())
            .map(PostInfo::from),
        Feed::Rss(ref feed) => feed.items()
            .iter()
            .find(|&item| item.link() == Some(post_url.as_str()))
            .map(PostInfo::from),
    };

    post_info.unwrap_or_default()
}

fn post_info(html: &str, url: &Url) -> Result<PostInfo, Error> {
    let ogobj = opengraph::extract(&mut html.as_bytes()).ok_or(Error::HtmlParseError)?;
    let doc = kuchiki::parse_html().one(html);

    // TODO: Defer this until needed
    let feed_info = find_feed(html, url)?
        .and_then(|feed| fetch_and_parse_feed(feed.url(), feed.feed_type()))
        .map(|feed| post_info_from_feed(url, &feed))
        .unwrap_or_default();

    let title = if ogobj.title != "" {
        ogobj.title
    } else {
        feed_info
            .title
            .clone()
            .or_else(|| {
                doc.select_first("title")
                    .ok()
                    .map(|title| title.text_contents())
            })
            .ok_or_else(|| Error::StringError("Document has no title".to_owned()))?
    }.trim()
        .to_owned();

    let description = match ogobj.description {
        Some(desc) => desc,
        None => doc.select_first("meta[name='description']")
            .ok()
            .and_then(|link| {
                let attrs = link.attributes.borrow();
                attrs.get("content").map(|content| content.to_owned())
            })
            .or_else(|| feed_info.description.clone())
            .unwrap_or_else(|| "FIXME".to_owned()),
    };

    let author = extract_author(&doc);
    let published_at = feed_info.published_at.or_else(|| extract_publication_date(&doc));

    Ok(PostInfo {
        title: Some(title),
        description: Some(description),
        author: Some(author),
        published_at,
    })
}

fn run(url_to_add: &str, tags: Vec<String>) -> Result<(), Error> {
    let feed_path = Path::new("content/_data/rust/posts.json");
    let mut feed = JsonFeed::load(feed_path)?;

    let url = Url::parse(url_to_add).map_err(Error::Url)?;
    let canonical_url = resolve_url(url)?;

    // Fetch page
    let mut response = reqwest::get(canonical_url.clone()).map_err(Error::Reqwest)?;
    let body = response.text().map_err(Error::Reqwest)?;
    let post_info = post_info(&body, &canonical_url)?;

    let item = Item {
        id: Uuid::new_v4(),
        title: post_info.title.expect("post is missing title"),
        url: canonical_url.to_string(),
        content_text: post_info.description.expect("post is missing description"),
        date_published: post_info
            .published_at
            .unwrap_or_else(|| FixedOffset::east(0).ymd(1970, 1, 1).and_hms(0, 0, 0)),
        author: post_info.author.expect("post is missing author"),
        tags: tags,
    };

    feed.add_item(item);

    feed.save(feed_path)
}

fn print_usage(program: &str, opts: &Options) {
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
        print_usage(&program, &opts);
        return;
    }

    run(&matches.free[0], matches.opt_strs("t")).expect("error");
}
