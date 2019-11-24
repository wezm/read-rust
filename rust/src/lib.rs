#[macro_use]
extern crate diesel;
#[macro_use]
extern crate log;

pub mod categories;
pub mod db;
pub mod mastodon;
pub mod models;
pub mod schema;
pub mod social_network;
pub mod twitter;

use std::env::VarError;
use std::ffi::OsStr;
use std::{env, fmt};

pub fn env_var<K: AsRef<OsStr>>(key: K) -> Result<String, ErrorMessage> {
    env::var(&key).map_err(|err| match err {
        VarError::NotPresent => ErrorMessage(format!(
            "environment variable '{}' is not set",
            key.as_ref().to_string_lossy()
        )),
        VarError::NotUnicode(_) => ErrorMessage(format!(
            "environment variable '{}' is not valid UTF-8",
            key.as_ref().to_string_lossy()
        )),
    })
}

#[derive(Debug)]
pub struct ErrorMessage(pub String);

impl fmt::Display for ErrorMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.0.fmt(f)
    }
}

impl std::error::Error for ErrorMessage {}
