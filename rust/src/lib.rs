#[macro_use]
extern crate diesel;
#[macro_use]
extern crate log;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate uuid;

pub mod categories;
pub mod db;
pub mod mastodon;
pub mod models;
pub mod schema;
pub mod twitter;

use std::fmt;

#[derive(Debug)]
pub struct ErrorMessage(pub String);

impl fmt::Display for ErrorMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.0.fmt(f)
    }
}

impl std::error::Error for ErrorMessage {}
