extern crate getopts;
extern crate read_rust;
extern crate mammut;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate uuid;

use getopts::Options;
use uuid::Uuid;
use mammut::{Data, Mastodon, Registration, StatusBuilder};
use mammut::apps::{AppBuilder, Scopes};

use read_rust::error::Error;
use read_rust::feed::{Item, JsonFeed};

use std::io;
use std::env;
use std::fs::File;
use std::path::Path;
use std::collections::HashSet;

const MASTODON_DATA_FILE: &str = ".mastodon-data.json";

#[derive(Debug, Serialize, Deserialize)]
struct Toot {
    pub item_id: Uuid,
}

#[derive(Debug, Serialize, Deserialize)]
struct TootList {
    toots: Vec<Toot>,
    uuids: HashSet<Uuid>,
}

impl TootList {
    pub fn load(path: &Path) -> Result<Self, Error> {
        let toot_list = File::open(path).map_err(Error::Io)?;
        let toots: Vec<Toot> = serde_json::from_reader(toot_list).map_err(Error::JsonError)?;
        let uuids = toots.iter().map(|toot| toot.item_id.clone()).collect();

        Ok(TootList { toots, uuids })
    }

    pub fn save(&self, path: &Path) -> Result<(), Error> {
        let toot_list = File::create(path).map_err(Error::Io)?;
        serde_json::to_writer_pretty(toot_list, &self.toots).map_err(Error::JsonError)
    }

    pub fn add_item(&mut self, item: Toot) {
        let uuid = item.item_id.clone();
        self.toots.push(item);
        self.uuids.insert(uuid);
    }

    pub fn contains(&self, uuid: &Uuid) -> bool {
        self.uuids.contains(uuid)
    }
}

fn connect_to_mastodon() -> Result<Mastodon, Error> {
    match File::open(MASTODON_DATA_FILE) {
        Ok(file) => {
            let data: Data = serde_json::from_reader(file).map_err(Error::JsonError)?;
            Ok(Mastodon::from_data(data))
        },
        Err(_) => register(),
    }
}

fn register() -> Result<Mastodon, Error> {
    let app = AppBuilder {
        client_name: "read-rust",
        redirect_uris: "urn:ietf:wg:oauth:2.0:oob",
        scopes: Scopes::Write,
        website: Some("https://readrust.net/"),
    };

    let mut registration = Registration::new("https://botsin.space");
    registration.register(app).map_err(Error::Mastodon)?;
    let url = registration.authorise().map_err(Error::Mastodon)?;

    println!("Click this link to authorize on Mastodon: {}", url);
    println!("Paste the returned authorization code: ");

    let mut input = String::new();
    let _ = io::stdin().read_line(&mut input).map_err(Error::Io)?;

    let code = input.trim();
    let mastodon = registration.create_access_token(code.to_string()).map_err(Error::Mastodon)?;

    // Save app data for using on the next run.
    let file = File::create(MASTODON_DATA_FILE).expect("Unable to create mastodon data file");
    let _ = serde_json::to_writer_pretty(file, &*mastodon).map_err(Error::JsonError)?;

    Ok(mastodon)
}

fn toot_text_from_item(item: &Item) -> String {
    // Mastodon doesn't allow dashes in tags, which makes some of the longer tags a bit awkward. So
    // leaving off for now.
    // let tags = item.tags.iter()
    //     .map(|tag| format!("#{}", tag.to_lowercase().replace(" ", "-")))
    //     .collect::<Vec<String>>()
    //     .join(" ");

    format!("{title} by {author}: {url} #Rust", title = item.title, author = item.author.name, url = item.url)
}

fn run(tootlist_path: &str, json_feed_path: &str, dry_run: bool) -> Result<(), Error> {
    let tootlist_path = Path::new(tootlist_path);
    let mut tootlist = TootList::load(&tootlist_path)?;
    let feed = JsonFeed::load(Path::new(json_feed_path))?;

    let to_toot: Vec<Item> = feed.items.into_iter().filter(|item| !tootlist.contains(&item.id)).collect();

    if to_toot.is_empty() {
        println!("Nothing to toot!");
        return Ok(());
    }

    let mastodon = connect_to_mastodon()?;
    for item in to_toot {
        let status_text = toot_text_from_item(&item);
        println!("• {}", status_text);
        if !dry_run {
            let _toot = mastodon.new_status(StatusBuilder::new(status_text)).map_err(Error::Mastodon)?;
        }
        tootlist.add_item(Toot { item_id: item.id });
    }

    if dry_run {
        Ok(())
    }
    else {
        tootlist.save(&tootlist_path)
    }
}

fn print_usage(program: &str, opts: &Options) {
    let usage = format!("Usage: {} [options] tootlist.json jsonfeed.json", program);
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

    run(&matches.free[0], &matches.free[1], matches.opt_present("n")).expect("error");
}
