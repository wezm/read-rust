extern crate chrono;
extern crate getopts;
extern crate read_rust;
extern crate rss;
extern crate serde_json;
extern crate url;

use std::env;
use std::fs::File;
use std::path::Path;

use rss::{ChannelBuilder, GuidBuilder, ItemBuilder};

use chrono::{DateTime, Datelike, FixedOffset};
use getopts::Options;
use url::Url;

use read_rust::feed::{Author, Item, JsonFeed};
use read_rust::error::Error;

const MAX_ITEMS: usize = 100;

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
        if let Some(url) = item.author.url {
            let _ = unwrap_placeholder(&url)?;
        }

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

fn generate_rss_items(feed: &JsonFeed, tag: &Option<String>) -> Result<Vec<rss::Item>, Error> {
    let mut sorted_items = feed.items.clone();
    sorted_items.sort_by(|a, b| b.date_published.cmp(&a.date_published));

    sorted_items
        .into_iter()
        .take(MAX_ITEMS)
        .filter_map(|item| match *tag {
            Some(ref tag) => if item.tags.contains(tag) {
                Some(item.try_into())
            } else {
                None
            },
            None => Some(item.try_into()),
        })
        .collect()
}

fn generate_rss(feed: &JsonFeed, rss_feed_path: &str, tag: &Option<String>) -> Result<(), Error> {
    let items = generate_rss_items(feed, tag)?;

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

fn generate_json_feed(
    feed: &JsonFeed,
    json_feed_path: &Path,
    tag: &Option<String>,
) -> Result<JsonFeed, Error> {
    let filtered_items = match *tag {
        Some(ref tag) => feed.items
            .clone()
            .into_iter()
            .filter(|item| item.tags.contains(tag))
            .collect(),
        None => feed.items.clone(),
    };

    let tag_name = tag.clone().unwrap_or_else(|| "All Posts".to_owned());
    let mut slug = tag.clone()
        .unwrap_or_else(|| "all".to_owned())
        .to_lowercase()
        .replace(" ", "-");
    slug.push_str("/");
    let home_page_url: Url = "https://readrust.net/".parse()?;

    let filtered_feed = JsonFeed {
        version: "https://jsonfeed.org/version/1".to_owned(),
        title: format!("Read Rust - {}", tag_name),
        home_page_url: home_page_url.clone(),
        feed_url: home_page_url.join(&slug).and_then(|url| url.join("feed.json"))?,
        description: format!("{} posts on Read Rust", tag_name),
        author: Author {
            name: "Wesley Moore".to_owned(),
            url: Some("http://www.wezm.net/".to_owned()),
        },
        items: filtered_items,
    };

    let file = File::create(json_feed_path).map_err(Error::Io)?;
    serde_json::to_writer_pretty(file, &filtered_feed).map_err(Error::JsonError)?;

    Ok(filtered_feed)
}

fn print_usage(program: &str, opts: &Options) {
    let brief = format!(
        "Usage: {} [options] input-feed.json output-feed.rss",
        program
    );
    print!("{}", opts.usage(&brief));
}

fn run(input_feed_path: &str, rss_feed_path: &str, tag: &Option<String>) -> Result<(), Error> {
    let feed = JsonFeed::load(Path::new(input_feed_path))?;

    let json_feed_path = Path::new(rss_feed_path).with_extension("json");
    let filtered_feed = generate_json_feed(&feed, &json_feed_path, tag)?;
    generate_rss(&filtered_feed, rss_feed_path, tag)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optopt(
        "t",
        "tag",
        "generate RSS feed from posts with this tag",
        "TAG",
    );
    opts.optflag("h", "help", "print this help menu");
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => m,
        Err(f) => panic!(f.to_string()),
    };
    if matches.opt_present("h") || matches.free.is_empty() {
        print_usage(&program, &opts);
        return;
    }

    run(&matches.free[0], &matches.free[1], &matches.opt_str("t")).expect("error");
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
