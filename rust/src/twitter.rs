use std::error::Error;
use std::rc::Rc;

use egg_mode::tweet::DraftTweet;

use tokio::runtime::current_thread::block_on_all;
use url::Url;

use crate::categories::Category;
use crate::models::Post;
use crate::social_network::{AccessMode, SocialNetwork};
use crate::{db, env_var, ErrorMessage};
use diesel::{PgConnection, QueryResult};

pub struct Twitter {
    token: egg_mode::Token,
    access_mode: AccessMode,
}

impl SocialNetwork for Twitter {
    fn from_env(access_mode: AccessMode) -> Result<Self, Box<dyn Error>> {
        let token = egg_mode::Token::Access {
            consumer: egg_mode::KeyPair::new(
                env_var("TWITTER_CONSUMER_KEY")?,
                env_var("TWITTER_CONSUMER_SECRET")?,
            ),
            access: egg_mode::KeyPair::new(
                env_var("TWITTER_ACCESS_KEY")?,
                env_var("TWITTER_ACCESS_SECRET")?,
            ),
        };

        Ok(Twitter { token, access_mode })
    }

    fn register() -> Result<(), Box<dyn Error>> {
        let consumer_key = env_var("TWITTER_CONSUMER_KEY")?;
        let consumer_secret = env_var("TWITTER_CONSUMER_SECRET")?;
        let con_token = egg_mode::KeyPair::new(consumer_key, consumer_secret);
        let request_token = block_on_all(egg_mode::request_token(&con_token, "oob"))?;

        println!("Go to the following URL, sign in, and enter the PIN:");
        println!("{}", egg_mode::authorize_url(&request_token));

        let mut pin = String::new();
        std::io::stdin().read_line(&mut pin)?;
        println!();

        let (token, _user_id, _screen_name) =
            block_on_all(egg_mode::access_token(con_token, &request_token, pin))?;

        match token {
            egg_mode::Token::Access { consumer, access } => {
                println!("TWITTER_CONSUMER_KEY={}", consumer.key);
                println!("TWITTER_CONSUMER_SECRET={}", consumer.secret);
                println!("TWITTER_ACCESS_KEY={}", access.key);
                println!("TWITTER_ACCESS_SECRET={}", access.secret);

                Ok(())
            }
            egg_mode::Token::Bearer(_) => {
                return Err(ErrorMessage(
                    "Received Bearer token but expected Access token".to_string(),
                )
                .into())
            }
        }
    }

    fn unpublished_posts(connection: &PgConnection) -> QueryResult<Vec<Post>> {
        db::untweeted_posts(connection)
    }

    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>> {
        if let Some(tweet_url) = &post.twitter_url {
            let tweet_id = tweet_id_from_url(&tweet_url)
                .ok_or_else(|| ErrorMessage(format!("{} is not a valid tweet URL", tweet_url)))?;
            info!("🔁 Tweet {}", tweet_url);
            if self.is_read_write() {
                let work = egg_mode::tweet::retweet(tweet_id, &self.token);
                block_on_all(work)?;
            }
        } else {
            let status_text = tweet_text_from_post(post, categories);
            info!("Tweet {}", status_text);
            let tweet = DraftTweet::new(status_text);

            if self.is_read_write() {
                let work = tweet.send(&self.token);
                block_on_all(work)?;
            }
        };

        Ok(())
    }

    fn mark_post_published(&self, connection: &PgConnection, post: Post) -> QueryResult<()> {
        if self.is_read_write() {
            db::mark_post_tweeted(connection, post)?;
        }

        Ok(())
    }
}

impl Twitter {
    fn is_read_write(&self) -> bool {
        self.access_mode == AccessMode::ReadWrite
    }
}

fn tweet_text_from_post(post: &Post, categories: &[Rc<Category>]) -> String {
    let hashtags = categories
        .iter()
        .map(|category| category.hashtag.as_str())
        .collect::<Vec<&str>>()
        .join(" ");

    format!(
        "{title} by {author}: {url} {tags}",
        title = post.title,
        author = post.author,
        url = post.url,
        tags = hashtags
    )
}

// https://twitter.com/llogiq/status/1012438300781576192
fn tweet_id_from_url(url: &str) -> Option<u64> {
    let url: Url = url.parse().ok()?;
    if url.domain() != Some("twitter.com") {
        return None;
    }

    let segments = url.path_segments().map(|iter| iter.collect::<Vec<_>>())?;
    match segments.as_slice() {
        [_, "status", id] => id.parse().ok(),
        _ => None,
    }
}

#[test]
fn test_tweet_id_from_valid_url() {
    assert_eq!(
        tweet_id_from_url(&"https://twitter.com/llogiq/status/1012438300781576192"),
        Some(1012438300781576192)
    );
}

#[test]
fn test_tweet_id_from_invalid_url() {
    assert_eq!(
        tweet_id_from_url(&"https://not_twitter.com/llogiq/status/1012438300781576192"),
        None
    );
}

#[test]
fn test_tweet_id_from_non_status_url() {
    assert_eq!(tweet_id_from_url(&"https://twitter.com/rustlang/"), None);
}

#[test]
fn test_tweet_id_from_almost_valid_url() {
    assert_eq!(
        tweet_id_from_url(
            &"https://mobile.twitter.com/shaneOsbourne/status/1012451814338424832/photo/2"
        ),
        None
    );
}
