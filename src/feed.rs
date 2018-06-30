extern crate chrono;
extern crate reqwest;
extern crate url;
extern crate url_serde;

use std::io::{Read, Write};
use std::path::Path;
use std::fs::File;

use atom_syndication as atom;
use rss;
use self::chrono::{DateTime, FixedOffset};
use serde_json;
use self::url::Url;
use uuid::Uuid;

use error::Error;

#[derive(Default, Debug)]
pub struct PostInfo {
    pub title: Option<String>,
    pub description: Option<String>,
    pub author: Option<Author>,
    pub published_at: Option<DateTime<FixedOffset>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Author {
    pub name: String,
    pub url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Item {
    pub id: Uuid,
    pub title: String,
    pub content_text: String,
    pub url: String,
    pub date_published: DateTime<FixedOffset>, // (Example: 2010-02-07T14:04:00-05:00.)
    pub author: Author,
    pub tags: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct JsonFeed {
    pub version: String,
    pub title: String,
    #[serde(with = "url_serde")]
    pub home_page_url: Url,
    #[serde(with = "url_serde")]
    pub feed_url: Url,
    pub description: String,
    pub author: Author,
    pub items: Vec<Item>,
}

#[derive(Debug)]
pub enum Feed {
    Json(JsonFeed),
    Rss(rss::Channel),
    Atom(atom::Feed),
}

impl JsonFeed {
    pub fn add_item(&mut self, item: Item) {
        self.items.insert(0, item);
    }

    pub fn load(path: &Path) -> Result<Self, Error> {
        let mut buffer = String::new();
        let mut feed_file = File::open(path).map_err(Error::Io)?;
        feed_file.read_to_string(&mut buffer).map_err(Error::Io)?;

        serde_json::from_str(&buffer).map_err(Error::JsonError)
    }

    pub fn save(&self, path: &Path) -> Result<(), Error> {
        let serialized = serde_json::to_string_pretty(self).unwrap();

        let mut feed_file = File::create(path).map_err(Error::Io)?;
        feed_file
            .write_all(serialized.as_bytes())
            .map_err(Error::Io)
    }
}

impl<'a> From<&'a atom::Entry> for PostInfo {
    fn from(entry: &atom::Entry) -> Self {
        // TODO: Get author from feed
        let author = entry.authors().first().map(Author::from);

        PostInfo {
            title: Some(entry.title().to_owned()),
            description: entry.summary().map(|desc| desc.to_owned()),
            author: author,
            published_at: entry
                .published()
                .and_then(|date| DateTime::parse_from_rfc3339(date).ok()),
        }
    }
}

impl<'a> From<&'a rss::Item> for PostInfo {
    fn from(item: &rss::Item) -> Self {
        PostInfo {
            title: item.title().map(|title| title.to_owned()),
            description: item.description().map(|desc| desc.to_owned()),
            author: None, // TODO: From
            published_at: item.pub_date()
                .and_then(|date| DateTime::parse_from_rfc2822(date).ok()),
        }
    }
}

impl<'a> From<&'a Item> for PostInfo {
    fn from(item: &Item) -> Self {
        PostInfo {
            title: Some(item.title.clone()),
            description: Some(item.content_text.clone()),
            author: None, // TODO: From
            published_at: Some(item.date_published),
        }
    }
}

impl<'a> From<&'a atom::Person> for Author {
    fn from(person: &atom::Person) -> Self {
        Author {
            name: person.name().to_owned(),
            url: person.uri().map(|uri| uri.to_owned()),
        }
    }
}
