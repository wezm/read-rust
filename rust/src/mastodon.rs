extern crate failure;
extern crate getopts;
extern crate mammut;
extern crate serde;
extern crate serde_json;
extern crate uuid;

use self::getopts::Options;
use self::mammut::apps::{AppBuilder, Scopes};
use self::mammut::{Data, Mastodon, Registration, StatusBuilder};
use failure::ResultExt;

use crate::categories::Categories;
use crate::feed::{Item, JsonFeed};
use crate::toot_list::{Toot, TootList};

use std::env;
use std::error::Error;
use std::io;
use std::path::Path;

pub fn client_from_env() -> Result<Mastodon, Box<dyn Error>> {
    let data = Data {
        base: env::var("MASTODON_BASE")?.into(),
        client_id: env::var("MASTODON_CLIENT_ID")?.into(),
        client_secret: env::var("MASTODON_CLIENT_SECRET")?.into(),
        redirect: env::var("MASTODON_REDIRECT")?.into(),
        token: env::var("MASTODON_TOKEN")?.into(),
    };

    Ok(Mastodon::from_data(data))
}

pub fn register() -> Result<Mastodon, Box<dyn Error>> {
    let app = AppBuilder {
        client_name: "read-rust",
        redirect_uris: "urn:ietf:wg:oauth:2.0:oob",
        scopes: Scopes::Write,
        website: Some("https://readrust.net/"),
    };

    let mut registration = Registration::new("https://botsin.space");
    registration.register(app)?;
    let url = registration.authorise()?;

    println!("Click this link to authorize on Mastodon: {}", url);
    println!("Paste the returned authorization code: ");

    let mut input = String::new();
    let _ = io::stdin().read_line(&mut input)?;

    let code = input.trim();
    let mastodon = registration.create_access_token(code.to_string())?;

    Ok(mastodon)
}

fn toot_text_from_item(item: &Item, categories: &Categories) -> String {
    let tags = item
        .tags
        .iter()
        .filter_map(|tag| {
            categories
                .hashtag_for_category(tag)
                .map(|hashtag| format!("#{}", hashtag))
        })
        .collect::<Vec<String>>()
        .join(" ");

    format!(
        "{title} by {author}: {url} #Rust {tags}",
        title = item.title,
        author = item.author.name,
        url = item.url,
        tags = tags
    )
}

fn run(
    tootlist_path: &str,
    json_feed_path: &str,
    categories_path: &str,
    dry_run: bool,
) -> Result<(), Box<dyn Error>> {
    let tootlist_path = Path::new(tootlist_path);
    let mut tootlist = TootList::load(&tootlist_path).compat()?;
    let feed = JsonFeed::load(Path::new(json_feed_path)).compat()?;
    let categories_path = Path::new(categories_path);
    let categories = Categories::load(&categories_path).compat()?;

    let to_toot: Vec<Item> = feed
        .items
        .into_iter()
        .filter(|item| !tootlist.contains(&item.id))
        .collect();

    if to_toot.is_empty() {
        println!("Nothing to toot!");
        return Ok(());
    }

    let mastodon = client_from_env()?;
    for item in to_toot {
        let status_text = toot_text_from_item(&item, &categories);
        println!("• {}", status_text);
        if !dry_run {
            let _toot = mastodon.new_status(StatusBuilder::new(status_text))?;
        }
        tootlist.add_item(Toot { item_id: item.id });
    }

    if !dry_run {
        let _ = tootlist.save(&tootlist_path).compat()?;
    }

    Ok(())
}

fn print_usage(program: &str, opts: &Options) {
    let usage = format!(
        "Usage: {} [options] tootlist.json jsonfeed.json categories.json",
        program
    );
    print!("{}", opts.usage(&usage));
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optflag("h", "help", "print this help menu");
    opts.optflag("n", "dryrun", "don't toot, just show what would be tooted");
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
    )
    .expect("error");
}
