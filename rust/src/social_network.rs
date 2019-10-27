use std::error::Error;
use std::rc::Rc;

use diesel::pg::PgConnection;
use diesel::prelude::*;
use mammut::Mastodon;

use crate::categories::Category;
use crate::models::Post;
use crate::{db, mastodon, twitter, ErrorMessage};
use std::env;

#[derive(Debug, Clone, Copy)]
pub enum AccessMode {
    ReadOnly,
    ReadWrite,
}

pub trait SocialNetwork: Sized {
    fn from_env(access_mode: AccessMode) -> Result<Self, Box<dyn Error>>;

    fn register() -> Result<(), Box<dyn Error>>;

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>>;

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>>;

    fn mark_post_published(connection: &PgConnection, post: Post) -> QueryResult<()>;
}
