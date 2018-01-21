extern crate read_rust;
extern crate rss;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;

use std::env;
use std::fs::File;
use std::path::Path;

use rss::{ChannelBuilder, ItemBuilder, GuidBuilder};

use read_rust::feed::{Feed};
use read_rust::error::Error;

const ARG_COUNT: usize = 3;

#[derive(Serialize)]
struct Post<'a> {
    title: &'a str,
    url: &'a str,
    author_name: &'a str,
}

fn generate_rss_items(feed: &Feed) -> Result<Vec<rss::Item>, Error> {
    let mut items = Vec::with_capacity(feed.items.len());

    for item in feed.items.iter() {
        let guid = GuidBuilder::default()
            .value(item.id.to_string())
            .permalink(false)
            .build()
            .map_err(|err| Error::StringError(err))?;

        let dc_extension = rss::extension::dublincore::DublinCoreExtensionBuilder::default()
            .creators(vec![item.author.name.clone()])
            .build()
            .map_err(|err| Error::StringError(err))?;

        let item = ItemBuilder::default()
            .guid(Some(guid))
            .title(item.title.clone())
            .link(item.url.clone())
            .description(item.content_text.clone())
            .pub_date(item.date_published.to_rfc2822())
            .dublin_core_ext(dc_extension)
            .build()
            .map_err(|err| Error::StringError(err))?;
        items.push(item);
    }

    Ok(items)
}

fn generate_rss(feed: &Feed, rss_feed_path: &str) -> Result<(), Error> {
    let items = generate_rss_items(feed)?;

    let channel = ChannelBuilder::default()
        .title(feed.title.clone())
        .link(feed.home_page_url.clone())
        .description(feed.description.clone())
        .items(items)
        .build()
        .map_err(|err| Error::StringError(err))?;

    let rss_file = File::create(rss_feed_path).map_err(|err| Error::Io(err))?;
    match channel.write_to(rss_file) {
        Ok(_) => Ok(()),
        Err(err) => Err(Error::RssError(err))
    }
}

fn generate_site_data(feed: &Feed, site_data_path: &str) -> Result<(), Error> {
    let mut sorted_items = feed.items.clone();
    sorted_items.sort_by(|a, b| b.date_published.cmp(&a.date_published));

    let posts: Vec<Post> = sorted_items.iter().map(|item| Post {
        title: &item.title,
        url: &item.url,
        author_name: &item.author.name,
    }).collect();

    let file = File::create(site_data_path).map_err(|err| Error::Io(err))?;
    serde_json::to_writer_pretty(file, &posts).map_err(|err| Error::JsonError(err))
}

fn run(json_feed_path: &str, rss_feed_path: &str, site_data_path: &str) -> Result<(), Error> {
    let feed = Feed::load(&Path::new(json_feed_path))?;

    generate_rss(&feed, rss_feed_path)
        .and_then(|()| generate_site_data(&feed, site_data_path))

}

fn main() {
    let args = env::args().skip(1).take(ARG_COUNT).collect::<Vec<_>>();

    if args.len() != ARG_COUNT {
        println!("Usage: generate-rss feed.json feed.rss site-data/feeds.json");
        std::process::exit(1);
    }

    run(&args[0], &args[1], &args[2]).expect("error!");
}
