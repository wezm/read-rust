extern crate egg_mode;
extern crate getopts;
extern crate read_rust;
extern crate tokio_core;
extern crate uuid;

use getopts::Options;
use egg_mode::tweet::DraftTweet;
use tokio_core::reactor::Core;

use read_rust::error::Error;
use read_rust::feed::{Item, JsonFeed};
use read_rust::toot_list::{Toot, TootList};

use std::io::{Read, Write};
use std::env;
use std::path::Path;

const TWITTER_DATA_FILE: &str = ".twitter-data.txt";

// From: https://github.com/QuietMisdreavus/twitter-rs/blob/master/examples/common/mod.rs
pub struct Config {
    pub token: egg_mode::Token,
    pub user_id: u64,
    pub screen_name: String,
}

impl Config {
    pub fn load(core: &mut Core) -> Self {
        // Make an app for yourself at apps.twitter.com and get your
        // key/secret into these files
        let consumer_key = include_str!(".consumer_key").trim();
        let consumer_secret = include_str!(".consumer_secret").trim();
        let handle = core.handle();

        let con_token = egg_mode::KeyPair::new(consumer_key, consumer_secret);

        let mut config = String::new();
        let user_id: u64;
        let username: String;
        let token: egg_mode::Token;

        //look at all this unwrapping! who told you it was my birthday?
        if let Ok(mut f) = std::fs::File::open(TWITTER_DATA_FILE) {
            f.read_to_string(&mut config).unwrap();

            let mut iter = config.split('\n');

            username = iter.next().unwrap().to_string();
            user_id = u64::from_str_radix(&iter.next().unwrap(), 10).unwrap();
            let access_token = egg_mode::KeyPair::new(
                iter.next().unwrap().to_string(),
                iter.next().unwrap().to_string(),
            );
            token = egg_mode::Token::Access {
                consumer: con_token,
                access: access_token,
            };

            if let Err(err) = core.run(egg_mode::verify_tokens(&token, &handle)) {
                println!("Unable to verify old tokens: {:?}", err);
                println!("Reauthenticating...");
                std::fs::remove_file(TWITTER_DATA_FILE).unwrap();
            } else {
                println!("Token for {} verified.", username);
            }
        } else {
            let request_token = core.run(egg_mode::request_token(&con_token, "oob", &handle))
                .unwrap();

            println!("Go to the following URL, sign in, and enter the PIN:");
            println!("{}", egg_mode::authorize_url(&request_token));

            let mut pin = String::new();
            std::io::stdin().read_line(&mut pin).unwrap();
            println!("");

            let tok_result = core.run(egg_mode::access_token(
                con_token,
                &request_token,
                pin,
                &handle,
            )).unwrap();

            token = tok_result.0;
            user_id = tok_result.1;
            username = tok_result.2;

            match token {
                egg_mode::Token::Access {
                    access: ref access_token,
                    ..
                } => {
                    config.push_str(&username);
                    config.push('\n');
                    config.push_str(&format!("{}", user_id));
                    config.push('\n');
                    config.push_str(&access_token.key);
                    config.push('\n');
                    config.push_str(&access_token.secret);
                }
                _ => unreachable!(),
            }

            let mut f = std::fs::File::create(TWITTER_DATA_FILE).unwrap();
            f.write_all(config.as_bytes()).unwrap();

            println!("Successfully authenticated as {}", username);
        }

        // TODO: Is there a better way to query whether a file exists?
        if std::fs::metadata(TWITTER_DATA_FILE).is_ok() {
            Config {
                token: token,
                user_id: user_id,
                screen_name: username,
            }
        } else {
            Self::load(core)
        }
    }
}

fn toot_text_from_item(item: &Item) -> String {
    // Mastodon doesn't allow dashes in tags, which makes some of the longer tags a bit awkward. So
    // leaving off for now.
    // let tags = item.tags.iter()
    //     .map(|tag| format!("#{}", tag.to_lowercase().replace(" ", "-")))
    //     .collect::<Vec<String>>()
    //     .join(" ");

    format!(
        "{title} by {author}: {url} #Rust",
        title = item.title,
        author = item.author.name,
        url = item.url
    )
}

fn run(tootlist_path: &str, json_feed_path: &str, dry_run: bool) -> Result<(), Error> {
    let mut core = Core::new().expect("unable to create core");
    let config = Config::load(&mut core);

    let handle = core.handle();

    let tootlist_path = Path::new(tootlist_path);
    let mut tootlist = TootList::load(&tootlist_path)?;
    let feed = JsonFeed::load(Path::new(json_feed_path))?;

    let to_tweet: Vec<Item> = feed.items
        .into_iter()
        .filter(|item| !tootlist.contains(&item.id))
        .collect();

    if to_tweet.is_empty() {
        println!("Nothing to tweet!");
        return Ok(());
    }

    for item in to_tweet {
        let status_text = toot_text_from_item(&item);
        println!("• {}", status_text);
        if !dry_run {
            let tweet = DraftTweet::new(status_text);

            let work = tweet.send(&config.token, &handle);
            core.run(work).expect("error in core.run");
        }
        tootlist.add_item(Toot { item_id: item.id });
    }

    if dry_run {
        Ok(())
    } else {
        tootlist.save(&tootlist_path)
    }
}

fn print_usage(program: &str, opts: &Options) {
    let usage = format!("Usage: {} [options] tweetlist.json jsonfeed.json", program);
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

    run(&matches.free[0], &matches.free[1], matches.opt_present("n")).expect("error");
}
