extern crate diesel;
extern crate dotenv;
extern crate env_logger;
extern crate failure;
extern crate getopts;
extern crate log;
extern crate read_rust;

use std::env::{self, VarError};
use std::error::Error;
use std::thread;

use dotenv::dotenv;
use env_logger::Env;
use failure::_core::time::Duration;
use getopts::Options;
use log::{error, debug, info};

use diesel::PgConnection;
use read_rust::db;

const LOG_ENV_VAR: &str = "READRUST_LOG";
const SLEEP_TIME: Duration = Duration::from_secs(60);

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
    opts.optflag("h", "help", "print this help menu");
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => m,
        Err(f) => panic!(f.to_string()),
    };
    if matches.opt_present("h") {
        print_usage(&program, &opts);
        return;
    }

    match run(matches.opt_present("t"), matches.opt_present("w")) {
        Ok(()) => {}
        Err(err) => {
            error!("Fatal Error: {}", err);
            std::process::exit(1);
        }
    }
}

fn print_usage(program: &str, opts: &Options) {
    let brief = format!("Usage: {} [options] URL", program);
    eprint!("{}", opts.usage(&brief));
}

fn run(toot: bool, tweet: bool) -> Result<(), Box<dyn Error>> {
    let database_url = env::var("DATABASE_URL")?;
    let conn = db::establish_connection(&database_url)?;
    info!("Connected to database");

    // TODO: Cleanly exit when sent sigint
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

        thread::sleep(SLEEP_TIME)
    }
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
