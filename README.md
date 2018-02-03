# Read Rust

Source code to [readrust.net][self]. A news aggregator for Rust news.
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

Running `make` will build the tools and gererate the site content.

[self]: http://readrust.net/
[contributing]: https://github.com/wezm/read-rust/blob/master/.github/contributing.md
[#Rust2018]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[Cobalt]: http://cobalt-org.github.io/
[install-cobalt]: http://cobalt-org.github.io/docs/install.html
