use env_logger;

use std::env;
use std::error::Error;
use std::thread;
use std::time::Duration;

use diesel::{Connection, PgConnection};
use dotenv::dotenv;
use env_logger::Env;
use getopts::Options;
use log::{debug, error, info};

use read_rust::categories::Categories;
use read_rust::mastodon::Mastodon;
use read_rust::social_network::{AccessMode, SocialNetwork};
use read_rust::twitter::Twitter;
use read_rust::{db, env_var};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

const LOG_ENV_VAR: &str = "READRUST_LOG";
const ONE_SECOND: Duration = Duration::from_secs(1);
const SLEEP_TIME: usize = 300; // 5 minutes

enum Service {
    Twitter,
    Mastodon,
}

fn main() {
    dotenv().ok();

    if let Err(env::VarError::NotPresent) = env::var(LOG_ENV_VAR) {
        env::set_var(LOG_ENV_VAR, "info");
    }

    let env = Env::new().filter(LOG_ENV_VAR);
    env_logger::init_from_env(env);

    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();

    let mut opts = Options::new();
    opts.optflag("n", "dryrun", "don't post statuses of update the db");
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
    let access_mode = if matches.opt_present("n") {
        AccessMode::ReadOnly
    } else {
        AccessMode::ReadWrite
    };

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
    } else if let Err(err) = run(
        access_mode,
        matches.opt_present("l"),
        matches.opt_present("t"),
        matches.opt_present("w"),
    ) {
        error!("Fatal Error: {}", err);
        std::process::exit(1);
    }
}

fn print_usage(program: &str, opts: &Options) {
    let brief = format!("Usage: {} [options] URL", program);
    eprint!("{}", opts.usage(&brief));
}

fn run(
    access_mode: AccessMode,
    doloop: bool,
    toot: bool,
    tweet: bool,
) -> Result<(), Box<dyn Error>> {
    let database_url = env_var("DATABASE_URL")?;
    let conn = db::establish_connection(&database_url)?;
    info!("Connected to database, access_mode: {:?}", access_mode);

    let categories = Categories::load();

    // create twiter and masto clients, with appropriate access mode
    let twitter = Twitter::from_env(access_mode)?;
    let mastodon = Mastodon::from_env(access_mode)?;

    debug!("Entering main loop");
    let term = Arc::new(AtomicBool::new(false));
    signal_hook::flag::register(signal_hook::SIGINT, Arc::clone(&term))?;
    signal_hook::flag::register(signal_hook::SIGTERM, Arc::clone(&term))?;

    while !term.load(Ordering::Relaxed) {
        if toot {
            debug!("Checking for new posts to toot");
            if let Err(err) = announce_new_posts(&mastodon, &conn, &categories) {
                // TODO: Log Sentry error
                error!("Error tooting new posts: {}", err);
            }
        }
        if term.load(Ordering::Relaxed) {
            break;
        }
        if tweet {
            debug!("Checking for new posts to tweet");
            if let Err(err) = announce_new_posts(&twitter, &conn, &categories) {
                error!("Error tweeting new posts: {}", err);
            }
        }

        if !doloop {
            break;
        }
        for _ in 0..SLEEP_TIME {
            if term.load(Ordering::Relaxed) {
                break;
            }
            thread::sleep(ONE_SECOND);
        }
    }

    Ok(())
}

fn announce_new_posts<S: SocialNetwork>(
    network: &S,
    conn: &PgConnection,
    categories: &Categories,
) -> Result<(), Box<dyn Error>> {
    for post in <S as SocialNetwork>::unpublished_posts(conn)? {
        let post_id = post.id;
        info!("New post to announce: [{}] {}", post_id, post.title);
        let toot_result = db::post_categories(conn, &post, categories)
            .map_err(|err| err.into())
            .and_then(|post_categories| {
                conn.transaction::<_, Box<dyn Error>, _>(|| {
                    network.publish_post(&post, &post_categories)?;
                    network.mark_post_published(conn, post)?;

                    Ok(())
                })
            });

        if let Err(err) = toot_result {
            error!("Unable to to announce publish post [{}]: {}", post_id, err);
        }
    }

    Ok(())
}

fn register(service: Service) -> Result<(), Box<dyn Error>> {
    match service {
        Service::Twitter => Twitter::register(),
        Service::Mastodon => Mastodon::register(),
    }
}
