extern crate reqwest;

use reqwest::{RedirectPolicy, Url, StatusCode};
use reqwest::header::Location;

#[derive(Debug)]
enum Error {
    Reqwest(reqwest::Error),
    Url(reqwest::UrlError),
}

fn resolve_url(url: Url) -> Result<Url, Error> {
    let client = reqwest::Client::builder()
        .redirect(RedirectPolicy::none())
        .build()
        .map_err(|err| Error::Reqwest(err))?;

    // HEAD url, if permanent redirect then follow
    // Else return URL
    let mut request_count = 0;
    let mut url = url;
    while request_count < 10 {
        let response = client.head(url.clone()).send().map_err(|err| Error::Reqwest(err))?;
        if response.status() == StatusCode::MovedPermanently {
            if let Some(next_url) = response.headers().get::<Location>() {
                let next_url = next_url.to_string();
                url = Url::parse(&next_url).map_err(|err| Error::Url(err))?;
            }
        }

        // TODO: Add check for success
        request_count += 1;
    }

    Ok(url)
}

fn run() -> Result<(), Error> {
    for url_str in std::env::args().skip(1) {
        let url = Url::parse(&url_str).map_err(|err| Error::Url(err))?;
        let canonical_url = resolve_url(url)?;

        // Use OpenGraph parser, fall back on title
        // Extract author as well
    }

    Ok(())
}

fn main() {
    run().expect("error");
}
