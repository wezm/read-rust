extern crate mammut;
extern crate reqwest;
extern crate rss;
extern crate url;

use std::io;
use serde_json;

#[derive(Debug, Fail)]
pub enum Error {
    #[fail(display = "HTTP error: {}", _0)] Reqwest(#[cause] reqwest::Error),
    #[fail(display = "URL error: {}", _0)] Url(#[cause] url::ParseError),
    #[fail(display = "HTML parsing error")] HtmlParseError,
    #[fail(display = "JSON parsing error: {}", _0)] JsonError(#[cause] serde_json::Error),
    #[fail(display = "{}", _0)] StringError(String),
    #[fail(display = "RSS error: {}", _0)] RssError(#[cause] rss::Error),
    #[fail(display = "IO error: {}", _0)] Io(#[cause] io::Error),
}

impl From<url::ParseError> for Error {
    fn from(err: url::ParseError) -> Self {
        Error::Url(err)
    }
}
