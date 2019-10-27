use std::error::Error;
use std::rc::Rc;

use diesel::pg::PgConnection;
use diesel::prelude::*;

use crate::categories::Category;
use crate::models::Post;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AccessMode {
    ReadOnly,
    ReadWrite,
}

pub trait SocialNetwork: Sized {
    fn from_env(access_mode: AccessMode) -> Result<Self, Box<dyn Error>>;

    fn register() -> Result<(), Box<dyn Error>>;

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>>;

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>>;

    fn mark_post_published(&self, connection: &PgConnection, post: Post) -> QueryResult<()>;
}
