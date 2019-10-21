extern crate diesel;
extern crate dotenv;
extern crate egg_mode;
extern crate env_logger;
extern crate failure;
extern crate getopts;
extern crate log;
extern crate read_rust;

use std::env::{self, VarError};
use std::error::Error;
use std::{fmt, thread};

use dotenv::dotenv;
use egg_mode::Token;
use env_logger::Env;
use failure::_core::time::Duration;
use getopts::Options;
use log::{debug, error, info};

use diesel::PgConnection;
use read_rust::{db, mastodon, twitter};

const LOG_ENV_VAR: &str = "READRUST_LOG";
const SLEEP_TIME: Duration = Duration::from_secs(60);

enum Service {
    Twitter,
    Mastodon,
}

#[derive(Debug)]
struct ErrorMessage(String);

fn main() {
    dotenv().ok();

    if let Err(VarError::NotPresent) = env::var(LOG_ENV_VAR) {
        env::set_var(LOG_ENV_VAR, "info");
    }

    let env = Env::new().filter(LOG_ENV_VAR);
    env_logger::init_from_env(env);

    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optflag("t", "toot", "toot new posts");
    opts.optflag("w", "tweet", "tweet new posts");
    opts.optflag("l", "loop", "enter loop checking for new posts");
    opts.optflag(
        "r",
        "register",
        "retrieve Twitter or Mastodon tokens (requires -t or -w as well)",
    );
    opts.optflag("h", "help", "print this help menu");
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => m,
        Err(f) => panic!(f.to_string()),
    };
    if matches.opt_present("h") {
        print_usage(&program, &opts);
        return;
    }

    if matches.opt_present("r") {
        let service = match (matches.opt_present("t"), matches.opt_present("w")) {
            (false, false) => {
                eprintln!("One of -t or -w is needed with -r");
                std::process::exit(1);
            }
            (true, false) => Service::Mastodon,
            (false, true) => Service::Twitter,
            (true, true) => {
                eprintln!("Only one of -t or -w is allowed with -r");
                std::process::exit(1);
            }
        };

        if let Err(err) = register(service) {
            error!("Registration Error: {}", err);
            std::process::exit(1);
        }
    } else {
        if let Err(err) = run(
            matches.opt_present("l"),
            matches.opt_present("t"),
            matches.opt_present("w"),
        ) {
            error!("Fatal Error: {}", err);
            std::process::exit(1);
        }
    }
}

fn print_usage(program: &str, opts: &Options) {
    let brief = format!("Usage: {} [options] URL", program);
    eprint!("{}", opts.usage(&brief));
}

fn run(doloop: bool, toot: bool, tweet: bool) -> Result<(), Box<dyn Error>> {
    let database_url = env::var("DATABASE_URL")?;
    let conn = db::establish_connection(&database_url)?;
    info!("Connected to database");

    // TODO: Cleanly exit when sent sigint
    debug!("Entering main loop");
    loop {
        if toot {
            debug!("Checking for new posts to toot");
            if let Err(err) = toot_new_posts(&conn) {
                // TODO: Log Sentry error
                error!("Error tooting new posts: {}", err);
            }
        }
        if tweet {
            debug!("Checking for new posts to tweet");
            if let Err(err) = tweet_new_posts(&conn) {
                error!("Error tweeting new posts: {}", err);
            }
        }

        if !doloop {
            break;
        }
        thread::sleep(SLEEP_TIME)
    }

    Ok(())
}

fn toot_new_posts(conn: &PgConnection) -> Result<(), Box<dyn Error>> {
    for post in db::untooted_posts(conn)? {
        info!("New post to toot: [{}] {}", post.id, post.title);
    }

    Ok(())
}

fn tweet_new_posts(conn: &PgConnection) -> Result<(), Box<dyn Error>> {
    for post in db::untweeted_posts(conn)? {
        info!("New post to tweet: [{}] {}", post.id, post.title);
    }

    Ok(())
}

fn register(service: Service) -> Result<(), Box<dyn Error>> {
    match service {
        Service::Twitter => {
            let consumer_key = env::var("TWITTER_CONSUMER_KEY")?;
            let consumer_secret = env::var("TWITTER_CONSUMER_SECRET")?;
            let token = twitter::register(consumer_key, consumer_secret)?;

            match token {
                Token::Access { consumer, access } => {
                    println!("TWITTER_CONSUMER_KEY={}", consumer.key);
                    println!("TWITTER_CONSUMER_SECRET={}", consumer.secret);
                    println!("TWITTER_ACCESS_KEY={}", access.key);
                    println!("TWITTER_ACCESS_SECRET={}", access.secret);

                    Ok(())
                }
                Token::Bearer(_) => Err(ErrorMessage(
                    "Received Bearer token but expected Access token".to_string(),
                )
                .into()),
            }
        }
        Service::Mastodon => {
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
    }
}

impl fmt::Display for ErrorMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.0.fmt(f)
    }
}

impl Error for ErrorMessage {}
