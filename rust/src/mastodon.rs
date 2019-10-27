use std::env;
use std::error::Error;
use std::io;
use std::rc::Rc;

use mammut::apps::{AppBuilder, Scopes};
use mammut::{Data, Mastodon as MastodonClient, Registration, StatusBuilder};

use crate::categories::Category;
use crate::db;
use crate::models::Post;
use crate::social_network::{AccessMode, SocialNetwork};
use diesel::{PgConnection, QueryResult};

pub struct Mastodon {
    client: MastodonClient,
    access_mode: AccessMode,
}

impl SocialNetwork for Mastodon {
    fn from_env(access_mode: AccessMode) -> Result<Self, Box<dyn Error>> {
        let data = Data {
            base: env::var("MASTODON_BASE")?.into(),
            client_id: env::var("MASTODON_CLIENT_ID")?.into(),
            client_secret: env::var("MASTODON_CLIENT_SECRET")?.into(),
            redirect: env::var("MASTODON_REDIRECT")?.into(),
            token: env::var("MASTODON_TOKEN")?.into(),
        };

        Ok(Mastodon {
            client: MastodonClient::from_data(data),
            access_mode,
        })
    }

    fn register() -> Result<(), Box<dyn Error>> {
        let app = AppBuilder {
            client_name: "read-rust",
            redirect_uris: "urn:ietf:wg:oauth:2.0:oob",
            scopes: Scopes::Write,
            website: Some("https://readrust.net/"),
        };

        let mut registration = Registration::new("https://botsin.space");
        registration.register(app)?;
        let url = registration.authorise()?;

        println!("Click this link to authorize on Mastodon: {}", url);
        println!("Paste the returned authorization code: ");

        let mut input = String::new();
        let _ = io::stdin().read_line(&mut input)?;

        let code = input.trim();
        let client = registration.create_access_token(code.to_string())?;

        // Print out the app data
        let data = &client.data;
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

    // FIXME: Boost existing status when present on post
    fn publish_post(&self, post: &Post, categories: &[Rc<Category>]) -> Result<(), Box<dyn Error>> {
        let status_text = toot_text_from_post(post, categories);
        info!("Toot {}", status_text);
        if self.is_read_write() {
            let _toot = self.client.new_status(StatusBuilder::new(status_text))?;
        }

        Ok(())
    }

    fn mark_post_published(&self, connection: &PgConnection, post: Post) -> QueryResult<()> {
        if self.is_read_write() {
            db::mark_post_tooted(connection, post)?;
        }

        Ok(())
    }
}

impl Mastodon {
    fn is_read_write(&self) -> bool {
        self.access_mode == AccessMode::ReadWrite
    }
}

fn toot_text_from_post(post: &Post, categories: &[Rc<Category>]) -> String {
    let hashtags = categories
        .iter()
        .map(|category| category.hashtag.as_str())
        .collect::<Vec<&str>>()
        .join(" ");

    format!(
        "{title} by {author}: {url} #Rust {tags}",
        title = post.title,
        author = post.author,
        url = post.url,
        tags = hashtags
    )
}
