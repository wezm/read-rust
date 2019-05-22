extern crate egg_mode;
#[macro_use]
extern crate failure;
extern crate getopts;
extern crate read_rust;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate tokio;
extern crate url;
extern crate uuid;

use egg_mode::tweet::DraftTweet;
use egg_mode::{KeyPair, Token};
use failure::Error;
use getopts::Options;
use tokio::runtime::current_thread::block_on_all;
use url::Url;

use read_rust::categories::Categories;
use read_rust::feed::{Item, JsonFeed};
use read_rust::toot_list::{Toot, TootList};

use std::borrow::Cow;
use std::env;
use std::fs::File;
use std::path::Path;

const TWITTER_DATA_FILE: &str = ".twitter-data.json";

// Serde calls this the definition of the remote type. It is just a copy of the
// remote type. The `remote` attribute gives the path to the actual type.
#[derive(Serialize, Deserialize, Clone)]
#[serde(remote = "KeyPair")]
struct KeyPairDef {
    pub key: Cow<'static, str>,
    pub secret: Cow<'static, str>,
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(remote = "Token")]
pub enum TokenDef {
    Access {
        #[serde(with = "KeyPairDef")]
        consumer: egg_mode::KeyPair,
        #[serde(with = "KeyPairDef")]
        access: egg_mode::KeyPair,
    },
    Bearer(String),
}

// Derived from: https://github.com/QuietMisdreavus/twitter-rs/blob/master/examples/common/mod.rs
#[derive(Deserialize, Serialize, Debug)]
pub struct Config {
    #[serde(with = "TokenDef")]
    pub token: Token,
    pub user_id: u64,
    pub screen_name: String,
}

impl Config {
    pub fn load() -> Result<Self, Error> {
        // Make an app for yourself at apps.twitter.com and get your
        // key/secret into these files
        let consumer_key = include_str!(".consumer_key").trim();
        let consumer_secret = include_str!(".consumer_secret").trim();

        let con_token = egg_mode::KeyPair::new(consumer_key, consumer_secret);

        let data_file_path = Path::new(TWITTER_DATA_FILE);
        let config = if let Ok(file) = File::open(data_file_path) {
            let config: Self = serde_json::from_reader(file)?;
            dbg!(&config);

            if let Err(err) = block_on_all(egg_mode::verify_tokens(&config.token)) {
                println!("Unable to verify old tokens: {:?}", err);
                println!("Reauthenticating...");
            } else {
                println!("Token for {} verified.", config.screen_name);
            }

            config
        } else {
            let request_token = block_on_all(egg_mode::request_token(&con_token, "oob"))?;

            println!("Go to the following URL, sign in, and enter the PIN:");
            println!("{}", egg_mode::authorize_url(&request_token));

            let mut pin = String::new();
            std::io::stdin().read_line(&mut pin)?;
            println!("");

            let (token, user_id, screen_name) =
                block_on_all(egg_mode::access_token(con_token, &request_token, pin))?;
            let config = Config {
                token,
                user_id,
                screen_name,
            };

            // Save app data for using on the next run.
            let file = File::create(TWITTER_DATA_FILE)?;
            let _ = serde_json::to_writer_pretty(file, &config)?;

            println!("Successfully authenticated as {}", config.screen_name);

            config
        };

        if data_file_path.exists() {
            Ok(config)
        } else {
            Self::load()
        }
    }
}

fn tweet_text_from_item(item: &Item, categories: &Categories) -> String {
    let tags = item.tags
        .iter()
        .filter_map(|tag| {
            categories
                .hashtag_for_category(tag)
                .map(|hashtag| format!("#{}", hashtag))
        })
        .collect::<Vec<String>>()
        .join(" ");

    format!(
        "{title} by {author}: {url} {tags}",
        title = item.title,
        author = item.author.name,
        url = item.url,
        tags = tags
    )
}

fn tweet_id_from_url(url: &Url) -> Option<u64> {
    // https://twitter.com/llogiq/status/1012438300781576192
    if url.domain() != Some("twitter.com") {
        return None;
    }

    let segments = url.path_segments().map(|iter| iter.collect::<Vec<_>>())?;
    match segments.as_slice() {
        [_, "status", id] => id.parse().ok(),
        _ => None,
    }
}

fn run(
    tootlist_path: &str,
    json_feed_path: &str,
    categories_path: &str,
    dry_run: bool,
) -> Result<(), Error> {
    let config = Config::load()?;
    let tootlist_path = Path::new(tootlist_path);
    let mut tootlist = TootList::load(&tootlist_path)?;
    let feed = JsonFeed::load(Path::new(json_feed_path))?;
    let categories_path = Path::new(categories_path);
    let categories = Categories::load(&categories_path)?;

    let to_tweet: Vec<Item> = feed.items
        .into_iter()
        .filter(|item| !tootlist.contains(&item.id))
        .collect();

    if to_tweet.is_empty() {
        println!("Nothing to tweet!");
        return Ok(());
    }

    for item in to_tweet {
        if let Some(tweet_url) = item.tweet_url {
            let tweet_id = tweet_id_from_url(&tweet_url)
                .ok_or_else(|| format_err!("{} is not a valid tweet URL", tweet_url))?;
            println!("🔁 {}", tweet_url);
            if !dry_run {
                let work = egg_mode::tweet::retweet(tweet_id, &config.token);
                block_on_all(work)?;
            }
        } else {
            let status_text = tweet_text_from_item(&item, &categories);
            println!("• {}", status_text);
            if !dry_run {
                let tweet = DraftTweet::new(status_text);

                let work = tweet.send(&config.token);
                block_on_all(work)?;
            }
        };

        tootlist.add_item(Toot { item_id: item.id });
    }

    if !dry_run {
        let _ = tootlist.save(&tootlist_path)?;
    }

    Ok(())
}

fn print_usage(program: &str, opts: &Options) {
    let usage = format!(
        "Usage: {} [options] tweetlist.json jsonfeed.json categories.json",
        program
    );
    print!("{}", opts.usage(&usage));
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optflag("h", "help", "print this help menu");
    opts.optflag(
        "n",
        "dryrun",
        "don't tweet, just show what would be tweeted",
    );
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => m,
        Err(f) => panic!(f.to_string()),
    };
    if matches.opt_present("h") || matches.free.is_empty() {
        print_usage(&program, &opts);
        return;
    }

    run(
        &matches.free[0],
        &matches.free[1],
        &matches.free[2],
        matches.opt_present("n"),
    ).expect("error");
}

#[test]
fn test_tweet_id_from_valid_url() {
    assert_eq!(tweet_id_from_url(&"https://twitter.com/llogiq/status/1012438300781576192".parse().unwrap()), Some(1012438300781576192));
}

#[test]
fn test_tweet_id_from_invalid_url() {
    assert_eq!(tweet_id_from_url(&"https://not_twitter.com/llogiq/status/1012438300781576192".parse().unwrap()), None);
}

#[test]
fn test_tweet_id_from_non_status_url() {
    assert_eq!(tweet_id_from_url(&"https://twitter.com/rustlang/".parse().unwrap()), None);
}

#[test]
fn test_tweet_id_from_almost_valid_url() {
    assert_eq!(tweet_id_from_url(&"https://mobile.twitter.com/shaneOsbourne/status/1012451814338424832/photo/2".parse().unwrap()), None);
}

