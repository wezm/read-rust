extern crate chrono;
extern crate read_rust;
extern crate rss;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;

use std::env;
use std::fs::File;
use std::path::Path;

use rss::{ChannelBuilder, GuidBuilder, ItemBuilder};

use chrono::{DateTime, Datelike, FixedOffset};

use read_rust::feed::{Feed, Item};
use read_rust::error::Error;

const ARG_COUNT: usize = 3;

#[derive(Serialize)]
struct Post<'a> {
    title: &'a str,
    url: &'a str,
    author_name: &'a str,
}

// Need TryFrom/Into https://github.com/sfackler/rfcs/blob/try-from/text/0000-try-from.md
pub trait TryFrom<T>: Sized {
    type Err;

    fn try_from(t: T) -> Result<Self, Self::Err>;
}

pub trait TryInto<T>: Sized {
    type Err;

    fn try_into(self) -> Result<T, Self::Err>;
}

impl<T, U> TryInto<U> for T
where
    U: TryFrom<T>,
{
    type Err = U::Err;

    fn try_into(self) -> Result<U, Self::Err> {
        U::try_from(self)
    }
}

fn unwrap_placeholder(text: &str) -> Result<String, Error> {
    if text.chars().all(char::is_whitespace) {
        Err(Error::StringError("value is empty string".to_owned()))
    } else if text == "FIXME" {
        Err(Error::StringError("value is FIXME".to_owned()))
    } else {
        Ok(text.to_owned())
    }
}

fn unwrap_date(date: &DateTime<FixedOffset>) -> Result<&DateTime<FixedOffset>, Error> {
    if date.year() < 2018 {
        Err(Error::StringError("date is before 2018".to_owned()))
    } else {
        Ok(date)
    }
}

impl TryFrom<Item> for rss::Item {
    type Err = Error;

    fn try_from(item: Item) -> Result<Self, Self::Err> {
        let guid = GuidBuilder::default()
            .value(item.id.to_string())
            .permalink(false)
            .build()
            .map_err(Error::StringError)?;

        let dc_extension = rss::extension::dublincore::DublinCoreExtensionBuilder::default()
            .creators(vec![unwrap_placeholder(&item.author.name)?])
            .build()
            .map_err(Error::StringError)?;

        // The author URL isn't used but verify that it's not a placeholder anyway
        let _ = unwrap_placeholder(&item.author.url)?;

        ItemBuilder::default()
            .guid(Some(guid))
            .title(unwrap_placeholder(&item.title)?)
            .link(item.url.clone())
            .description(unwrap_placeholder(&item.content_text)?)
            .pub_date(unwrap_date(&item.date_published)?.to_rfc2822())
            .dublin_core_ext(dc_extension)
            .build()
            .map_err(Error::StringError)
    }
}

fn generate_rss_items(feed: &Feed) -> Result<Vec<rss::Item>, Error> {
    feed.items
        .iter()
        .map(|item| item.clone().try_into())
        .collect()
}

fn generate_rss(feed: &Feed, rss_feed_path: &str) -> Result<(), Error> {
    let items = generate_rss_items(feed)?;

    let channel = ChannelBuilder::default()
        .title(feed.title.clone())
        .link(feed.home_page_url.clone())
        .description(feed.description.clone())
        .items(items)
        .build()
        .map_err(Error::StringError)?;

    let rss_file = File::create(rss_feed_path).map_err(Error::Io)?;
    match channel.write_to(rss_file) {
        Ok(_) => Ok(()),
        Err(err) => Err(Error::RssError(err)),
    }
}

fn generate_site_data(feed: &Feed, site_data_path: &str) -> Result<(), Error> {
    let mut sorted_items = feed.items.clone();
    sorted_items.sort_by(|a, b| b.date_published.cmp(&a.date_published));

    let posts: Vec<Post> = sorted_items
        .iter()
        .map(|item| Post {
            title: &item.title,
            url: &item.url,
            author_name: &item.author.name,
        })
        .collect();

    let file = File::create(site_data_path).map_err(Error::Io)?;
    serde_json::to_writer_pretty(file, &posts).map_err(Error::JsonError)
}

fn run(json_feed_path: &str, rss_feed_path: &str, site_data_path: &str) -> Result<(), Error> {
    let feed = Feed::load(Path::new(json_feed_path))?;

    generate_rss(&feed, rss_feed_path).and_then(|()| generate_site_data(&feed, site_data_path))
}

fn main() {
    let args = env::args().skip(1).take(ARG_COUNT).collect::<Vec<_>>();

    if args.len() != ARG_COUNT {
        println!("Usage: generate-rss feed.json feed.rss site-data/feeds.json");
        std::process::exit(1);
    }

    run(&args[0], &args[1], &args[2]).expect("error!");
}

#[test]
fn test_unwrap_placeholder() {
    assert!(unwrap_placeholder("").is_err());
    assert!(unwrap_placeholder("   ").is_err());
    assert!(unwrap_placeholder("FIXME").is_err());
    assert!(unwrap_placeholder("Ok").is_ok());
}

#[test]
fn test_unwrap_date() {
    use chrono::TimeZone;

    assert!(unwrap_date(&FixedOffset::east(0).ymd(1970, 1, 1).and_hms(0, 0, 0)).is_err());
    assert!(unwrap_date(&FixedOffset::east(0).ymd(2018, 1, 1).and_hms(0, 0, 0)).is_ok());
}
