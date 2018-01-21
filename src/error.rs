extern crate reqwest;
use serde_json;
extern crate rss;

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
}
