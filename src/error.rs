extern crate reqwest;
use serde_json;
extern crate rss;
extern crate mammut;

use std::io;

#[derive(Debug)]
pub enum Error {
    Reqwest(reqwest::Error),
    Url(reqwest::UrlError),
    HtmlParseError,
    JsonError(serde_json::Error),
    StringError(String),
    RssError(rss::Error),
    Io(io::Error),
    Mastodon(mammut::Error),
}
