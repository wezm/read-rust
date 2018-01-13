extern crate read_rust;
extern crate rss;

use std::env;
use std::fs::File;
use std::path::Path;

use rss::{ChannelBuilder, ItemBuilder, GuidBuilder};

use read_rust::feed::{Feed};
use read_rust::error::Error;

fn run(json_feed_path: &Path, rss_feed_path: &Path) -> Result<(), Error> {
    let feed = Feed::load(json_feed_path)?;

    let items: Vec<_> = feed.items.iter().map(|item| {
        let guid = GuidBuilder::default()
            .value(item.id.to_string())
            .permalink(false)
            .build()
            .expect("error building Guid");

        ItemBuilder::default()
            .guid(Some(guid))
            .title(item.title.clone())
            .link(item.url.clone())
            .description(item.content_text.clone())
            .build()
            .expect("error building Item")
    }).collect();

    let channel = ChannelBuilder::default()
        .title(feed.title)
        .link(feed.home_page_url)
        .description(feed.description)
        .items(items)
        .build()
        .map_err(|err| Error::StringError(err))?;

    let rss_file = File::create(rss_feed_path).map_err(|err| Error::Io(err))?;
    match channel.write_to(rss_file) {
        Ok(_) => Ok(()),
        Err(err) => Err(Error::RssError(err))
    }
}

fn main() {
    let args = env::args().skip(1).take(2).collect::<Vec<_>>();

    if args.len() != 2 {
        println!("Usage: generate-rss feed.json feed.rss");
        std::process::exit(1);
    }

    run(&Path::new(&args[0]), &Path::new(&args[1])).expect("error!");
}
