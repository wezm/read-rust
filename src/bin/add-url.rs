extern crate reqwest;
extern crate opengraph;
extern crate uuid;
#[macro_use]
extern crate serde_derive;

extern crate serde;
extern crate serde_json;

use std::io::{self, Read, Write};
use std::path::Path;
use std::fs::File;

use reqwest::{RedirectPolicy, Url, StatusCode};
use reqwest::header::Location;

use uuid::Uuid;

/*
{
    "version": "https://jsonfeed.org/version/1",
    "title": "#Rust2018",
    "home_page_url": "https://example.org/",
    "feed_url": "https://example.org/rust2018.json",
    "items": [
        {
            "id": "2",
            "content_text": "This is a second item.",
            "url": "https://example.org/second-item"
        },
        {
            "id": "1",
            "content_html": "<p>Hello, world!</p>",
            "url": "https://example.org/initial-post"
        }
    ]
}
*/

#[derive(Serialize, Deserialize)]
struct Author {
    name: String,
    url: String,
}

#[derive(Serialize, Deserialize)]
struct Item {
    id: Uuid,
    title: String,
    content_text: String,
    url: String,
    // date_published: Date (Example: 2010-02-07T14:04:00-05:00.)
    // author: Author,
}

#[derive(Serialize, Deserialize)]
struct Feed  {
    version: String,
    title: String,
    home_page_url: String,
    feed_url: String,
    description: String,
    author: Author,
    items: Vec<Item>,
}

#[derive(Debug)]
enum Error {
    Reqwest(reqwest::Error),
    Url(reqwest::UrlError),
    HtmlParseError,
    JsonParseError(serde_json::Error),
    Io(io::Error),
}

impl Feed {
    fn add_item(&mut self, item: Item) {
        self.items.insert(0, item);
    }

    fn load(path: &Path) -> Result<Feed, Error> {
        let mut buffer = String::new();
        let mut feed_file = File::open(path).map_err(|err| Error::Io(err))?;
        feed_file.read_to_string(&mut buffer).map_err(|err| Error::Io(err))?;

        serde_json::from_str(&buffer).map_err(|err| Error::JsonParseError(err))
    }

    fn save(&self, path: &Path) -> Result<(), Error> {
        let serialized = serde_json::to_string_pretty(self).unwrap();

        let mut feed_file = File::create(path).map_err(|err| Error::Io(err))?;
        feed_file.write_all(serialized.as_bytes()).map_err(|err| Error::Io(err))
    }
}

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
