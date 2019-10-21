extern crate failure;
extern crate getopts;
extern crate mammut;
extern crate serde;
extern crate serde_json;
extern crate uuid;

use self::mammut::apps::{AppBuilder, Scopes};
use self::mammut::{Data, Mastodon, Registration, StatusBuilder};

use categories::Category;
use models::Post;
use std::env;
use std::error::Error;
use std::io;
use std::rc::Rc;

pub fn client_from_env() -> Result<Mastodon, Box<dyn Error>> {
    let data = Data {
        base: env::var("MASTODON_BASE")?.into(),
        client_id: env::var("MASTODON_CLIENT_ID")?.into(),
        client_secret: env::var("MASTODON_CLIENT_SECRET")?.into(),
        redirect: env::var("MASTODON_REDIRECT")?.into(),
        token: env::var("MASTODON_TOKEN")?.into(),
    };

    Ok(Mastodon::from_data(data))
}

pub fn register() -> Result<Mastodon, Box<dyn Error>> {
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
    let mastodon = registration.create_access_token(code.to_string())?;

    Ok(mastodon)
}

// FIXME: Boost existing status when present on post
pub fn toot_post(
    client: &Mastodon,
    post: &Post,
    categories: &[Rc<Category>],
) -> Result<(), Box<dyn Error>> {
    let status_text = toot_text_from_post(post, categories);
    info!("Toot {}", status_text);
    let _toot = client.new_status(StatusBuilder::new(status_text))?;

    Ok(())
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
