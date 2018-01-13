extern crate reqwest;
extern crate opengraph;
extern crate read_rust;
extern crate uuid;

use std::path::Path;

use reqwest::{RedirectPolicy, Url, StatusCode};
use reqwest::header::Location;

use read_rust::feed::{Feed, Item};
use read_rust::error::Error;

use uuid::Uuid;

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

fn run() -> Result<(), Error> {
    let feed_path = Path::new("content/rust2018/feed.json");
    let mut feed = Feed::load(&feed_path)?;

    for url_str in std::env::args().skip(1) {
        let url = Url::parse(&url_str).map_err(|err| Error::Url(err))?;
        let canonical_url = resolve_url(url)?;

        // Fetch page
        let mut response = reqwest::get(canonical_url.clone()).map_err(|err| Error::Reqwest(err))?;
        let body = response.text().map_err(|err| Error::Reqwest(err))?;

        // Use OpenGraph parser, fall back on title
        let ogobj = opengraph::extract(&mut body.clone().as_bytes()).ok_or(Error::HtmlParseError)?;

        let item = Item {
            id: Uuid::new_v4(),
            title: ogobj.title,
            url: canonical_url.to_string(),
            content_text: ogobj.description.unwrap_or_else(|| "TODO".to_owned()),
            // date_published: Date (Example: 2010-02-07T14:04:00-05:00.)
            // author: Author,
        };

        feed.add_item(item);

        // Extract author as well?
    }

    feed.save(&feed_path)
}

fn main() {

    run().expect("error");
}
