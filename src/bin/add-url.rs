extern crate reqwest;
extern crate opengraph;
extern crate read_rust;
extern crate uuid;
extern crate kuchiki;
extern crate chrono;

use std::path::Path;

use reqwest::{RedirectPolicy, Url, StatusCode};
use reqwest::header::Location;

use read_rust::feed::{Feed, Item, Author};
use read_rust::error::Error;

use uuid::Uuid;
use kuchiki::traits::TendrilSink;
use chrono::{DateTime, FixedOffset};

fn resolve_url(url: Url) -> Result<Url, Error> {
    let client = reqwest::Client::builder()
        .redirect(RedirectPolicy::none())
        .build()
        .map_err(|err| Error::Reqwest(err))?;

    // HEAD url, if permanent redirect then follow
    // Else return URL
    let mut request_count = 0;
    let mut url = url;
    while request_count < 10 {
        let response = client.head(url.clone()).send().map_err(|err| Error::Reqwest(err))?;
        if response.status() == StatusCode::MovedPermanently {
            if let Some(next_url) = response.headers().get::<Location>() {
                let next_url = next_url.to_string();
                url = Url::parse(&next_url).map_err(|err| Error::Url(err))?;
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
    let author_url = doc.select_first("link[rel='author']").ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("href").map(|href| href.to_owned())
        });

    let author_name = doc.select_first("meta[name='author']").ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("content").map(|content| content.to_owned())
        })
        .or_else(|| {
            doc.select_first("meta[property='author']").ok()
            .and_then(|link| {
                let attrs = link.attributes.borrow();
                attrs.get("content").map(|content| content.to_owned())
            })
        })
        .or_else(|| {
            doc.select_first("meta[property='article:author']").ok()
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
    doc.select_first("meta[property='article:published_time']").ok()
        .and_then(|link| {
            let attrs = link.attributes.borrow();
            attrs.get("content").map(|content| content.to_owned())
        })
        .or_else(|| {
            doc.select_first("article time").ok()
            .and_then(|time| {
                let attrs = time.attributes.borrow();
                attrs.get("datetime").map(|content| content.to_owned())
            })
        })
        .and_then(|date| DateTime::parse_from_rfc3339(&date).ok())
}

fn post_info(html: &str) -> Result<PostInfo, Error> {
    let ogobj = opengraph::extract(&mut html.clone().as_bytes()).ok_or(Error::HtmlParseError)?;
    let doc = kuchiki::parse_html().one(html);

    let title = if ogobj.title != "" {
        ogobj.title
    }
    else {
        doc.select_first("title")
            .map_err(|_err| Error::StringError("Document has not title".to_owned()))?
            .text_contents()
    };

    let description = match ogobj.description {
        Some(desc) => desc,
        None => {
            doc.select_first("meta[name='description']").ok()
            .and_then(|link| {
                let attrs = link.attributes.borrow();
                attrs.get("content").map(|content| content.to_owned())
            })
            .unwrap_or_else(|| "FIXME".to_owned())
        },
    };

    let author = extract_author(&doc);
    let published_at = extract_publication_date(&doc);

    Ok(PostInfo { title, description, author, published_at })
}

fn run() -> Result<(), Error> {
    let feed_path = Path::new("content/rust2018/feed.json");
    let mut feed = Feed::load(&feed_path)?;

    for url_str in std::env::args().skip(1) {
        let url = Url::parse(&url_str).map_err(|err| Error::Url(err))?;
        let canonical_url = resolve_url(url)?;

        // Fetch page
        let mut response = reqwest::get(canonical_url.clone()).map_err(|err| Error::Reqwest(err))?;
        let body = response.text().map_err(|err| Error::Reqwest(err))?;
        let post_info = post_info(&body)?;

        let item = Item {
            id: Uuid::new_v4(),
            title: post_info.title,
            url: canonical_url.to_string(),
            content_text: post_info.description,
            date_published: post_info.published_at,
            author: post_info.author,
        };

        feed.add_item(item);
    }

    feed.save(&feed_path)
}

fn main() {

    run().expect("error");
}
