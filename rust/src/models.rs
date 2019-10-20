extern crate chrono;

use std::io::Write;

use self::chrono::{DateTime, FixedOffset, Utc};
use diesel::pg::Pg;
use diesel::serialize::{self, Output, ToSql};
use diesel::sql_types::{self, Text, Uuid};

#[derive(Queryable)]
pub struct Post {
    pub id: i64,
    pub guid: Uuid,
    pub title: String,
    pub url: String,
    pub twitter_url: Option<String>,
    pub mastodon_url: Option<String>,
    pub author: String,
    pub summary: String,
    pub tweeted_at: Option<DateTime<Utc>>,
    pub tooted_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Queryable)]
pub struct PostCategory {
    pub id: i64,
    pub post_id: i64,
    pub category_id: i16,
}
