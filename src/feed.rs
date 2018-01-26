extern crate chrono;
extern crate reqwest;

use std::io::{Read, Write};
use std::path::Path;
use std::fs::File;

use uuid::Uuid;
use serde_json;
use self::chrono::{DateTime, FixedOffset};

use error::Error;

#[derive(Serialize, Deserialize, Clone)]
pub struct Author {
    pub name: String,
    pub url: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Item {
    pub id: Uuid,
    pub title: String,
    pub content_text: String,
    pub url: String,
    pub date_published: DateTime<FixedOffset>, // (Example: 2010-02-07T14:04:00-05:00.)
    pub author: Author,
}

#[derive(Serialize, Deserialize)]
pub struct Feed {
    pub version: String,
    pub title: String,
    pub home_page_url: String,
    pub feed_url: String,
    pub description: String,
    pub author: Author,
    pub items: Vec<Item>,
}

impl Feed {
    pub fn add_item(&mut self, item: Item) {
        self.items.insert(0, item);
    }

    pub fn load(path: &Path) -> Result<Feed, Error> {
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
