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
use log::info;

use read_rust::models::Post;

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
            eprintln!("Error: {}", err);
            std::process::exit(1);
        }
    }
}

fn print_usage(program: &str, opts: &Options) {
    let brief = format!("Usage: {} [options] URL", program);
    print!("{}", opts.usage(&brief));
}

fn run(toot: bool, tweet: bool) -> Result<(), Box<dyn Error>> {
    // TODO: Cleanly exit when sent sigint
    loop {
        let posts: Vec<Post> = Vec::new();
        if toot {
            toot_posts(&posts); // Failure to toot is not fatal, carry on after logging
        }
        if tweet {
            tweet_posts(&posts);
        }

        thread::sleep(SLEEP_TIME)
    }
}

fn toot_posts(posts: &[Post]) -> Result<(), Box<dyn Error>> {
    Ok(())
}

fn tweet_posts(posts: &[Post]) -> Result<(), Box<dyn Error>> {
    Ok(())
}
