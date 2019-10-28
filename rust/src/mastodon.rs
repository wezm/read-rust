use std::error::Error;
use std::io;
use std::rc::Rc;

use diesel::{PgConnection, QueryResult};
use elefren::apps::App;
use elefren::scopes::Scopes;
use elefren::{Data, MastodonClient, Registration, StatusBuilder};

use crate::categories::Category;
use crate::db;
use crate::env_var;
use crate::models::Post;
use crate::social_network::{AccessMode, SocialNetwork};

pub struct Mastodon {
    client: elefren::Mastodon,
    access_mode: AccessMode,
}

impl SocialNetwork for Mastodon {
    fn from_env(access_mode: AccessMode) -> Result<Self, Box<dyn Error>> {
        let data = Data {
            base: env_var("MASTODON_BASE")?.into(),
            client_id: env_var("MASTODON_CLIENT_ID")?.into(),
            client_secret: env_var("MASTODON_CLIENT_SECRET")?.into(),
            redirect: env_var("MASTODON_REDIRECT")?.into(),
            token: env_var("MASTODON_TOKEN")?.into(),
        };

        Ok(Mastodon {
            client: elefren::Mastodon::from(data),
            access_mode,
        })
    }

    fn register() -> Result<(), Box<dyn Error>> {
        let base = env_var("MASTODON_BASE")?;
        let mut builder = App::builder();
        let scopes = Scopes::read_all() | Scopes::write(elefren::scopes::Write::Statuses);
        builder
            .client_name("Read Rust")
            .redirect_uris("urn:ietf:wg:oauth:2.0:oob")
            .scopes(scopes)
            .website("https://readrust.net/");
        let app = builder.build()?;

        let registration = Registration::new(base).register(app)?;
        let url = registration.authorize_url()?;

        println!("Click this link to authorize on Mastodon: {}", url);
        println!("Paste the returned authorization code: ");

        let mut input = String::new();
        let _ = io::stdin().read_line(&mut input)?;

        let code = input.trim();
        let client = registration.complete(code)?;

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
        if let Some(status_url) = &post.mastodon_url {
            // Need to reblog this status. Doing so requires knowing the id of the status on the
            // instance on which it will be reblogged from. It appears the only way to turn
            // a status URL into an ID is via search.
            let resolve = true; // Attempt WebFinger look-up
                                // println!(
                                //     "Search results = {:?}",
                                //     self.client.search_v2(status_url, resolve)
                                // );
        } else {
            let status_text = toot_text_from_post(post, categories);
            info!("Toot {}", status_text);

            if self.is_read_write() {
                let _toot = self
                    .client
                    .new_status(StatusBuilder::new().status(status_text).build()?)?;
            }
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
