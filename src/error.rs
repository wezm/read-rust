extern crate reqwest;
use serde_json;

use std::io;

#[derive(Debug)]
pub enum Error {
    Reqwest(reqwest::Error),
    Url(reqwest::UrlError),
    HtmlParseError,
    JsonParseError(serde_json::Error),
    Io(io::Error),
}

