# Read Rust

Source code to [readrust.net][self]. A news aggregator for following [#Rust2018].
This repo contains the source to the website and tools for updating the feeds.

[![Build Status](https://travis-ci.org/wezm/read-rust.svg?branch=master)](https://travis-ci.org/wezm/read-rust)

## Contributing

See the [contributing guidelines][contributing].

## Building

### Website

The website is built with [Cobalt]. After [installing Cobalt][install-cobalt]
the site can be built by running `make`.

### Tools

The tools are mostly written in Rust, so `cargo build --release` will build
them. The tools themselves are:

* `add-url` add a new entry to `feed.json`.
* `generate-rss` generates `feed.rss`, and the cobalt data from `feed.json`.

## The Feeds

Two feeds are published: [feed.json] and [feed.rss]. `feed.json` is a [JSON
Feed] and is the canonical feed. `feed.rss` is derived from `feed.json`. Don't
make manual edits to `feed.rss`.

[self]: http://readrust.net/
[contributing]: https://github.com/wezm/read-rust/blob/master/.github/contributing.md
[#Rust2018]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[Cobalt]: http://cobalt-org.github.io/
[install-cobalt]: http://cobalt-org.github.io/docs/install.html
[twurl]: https://github.com/twitter/twurl
[jq]: https://stedolan.github.io/jq/
[feed.json]: http://readrust.net/rust2018/feed.json
[feed.rss]: http://readrust.net/rust2018/feed.rss
[JSON Feed]: https://jsonfeed.org/
