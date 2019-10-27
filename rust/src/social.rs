use std::error::Error;
use std::rc::Rc;

use diesel::pg::PgConnection;
use diesel::prelude::*;
use mammut::Mastodon;

use crate::categories::Category;
use crate::models::Post;
use crate::{db, mastodon, twitter, ErrorMessage};
use std::env;

pub trait SocialNetwork {
    fn register() -> Result<(), Box<dyn Error>>;

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>>;

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>>;

    fn mark_post_published(connection: &PgConnection, post: Post) -> QueryResult<()>;
}

impl SocialNetwork for Mastodon {
    fn register() -> Result<(), Box<dyn Error>> {
        let client = mastodon::register()?;

        // Print out the app data
        let data = client.data;
        println!("MASTODON_BASE={}", data.base);
        println!("MASTODON_CLIENT_ID={}", data.client_id);
        println!("MASTODON_CLIENT_SECRET={}", data.client_secret);
        println!("MASTODON_REDIRECT={}", data.redirect);
        println!("MASTODON_TOKEN={}", data.token);

        Ok(())
    }

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>> {
        db::untooted_posts(connection)
    }

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>> {
        mastodon::toot_post(self, post, categories)
    }

    fn mark_post_published(connection: &PgConnection, post: Post) -> QueryResult<()> {
        db::mark_post_tooted(connection, post)
    }
}

impl SocialNetwork for egg_mode::Token {
    fn register() -> Result<(), Box<dyn Error>> {
        let consumer_key = env::var("TWITTER_CONSUMER_KEY")?;
        let consumer_secret = env::var("TWITTER_CONSUMER_SECRET")?;
        let token = twitter::register(consumer_key, consumer_secret)?;

        match token {
            egg_mode::Token::Access { consumer, access } => {
                println!("TWITTER_CONSUMER_KEY={}", consumer.key);
                println!("TWITTER_CONSUMER_SECRET={}", consumer.secret);
                println!("TWITTER_ACCESS_KEY={}", access.key);
                println!("TWITTER_ACCESS_SECRET={}", access.secret);

                Ok(())
            }
            egg_mode::Token::Bearer(_) => Err(ErrorMessage(
                "Received Bearer token but expected Access token".to_string(),
            )
            .into()),
        }
    }

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>> {
        db::untweeted_posts(connection)
    }

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>> {
        twitter::tweet_post(self, post, categories)
    }

    fn mark_post_published(connection: &PgConnection, post: Post) -> QueryResult<()> {
        db::mark_post_tweeted(connection, post)
    }
}
