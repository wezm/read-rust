# Read Rust

Source code to [readrust.net][self]. A news aggregator for Rust news.
This repo contains the source to the website and tools for updating the feeds.

[![Build Status](https://travis-ci.org/wezm/read-rust.svg?branch=master)](https://travis-ci.org/wezm/read-rust)

## Contributing

Check out the [Submission page on the website][contributing] for info on
submitting a post.

## Building

### Website

The website is built with [Cobalt]. After [installing Cobalt][install-cobalt]
the site can be built by running `make`.

### Tools

The tools are mostly written in Rust, so `cargo build --release` will build
them. The tools themselves are:

* `add-url` add a new entry to `feed.json`.
* `generate-rss` generates `feed.rss`, and the cobalt data from `feed.json`.

Running `make` will build the tools and generate the site content.

## Notes

### Adding a New Category

1. Add an entry to `content/_data/categories.json`
2. Add a new content directory and index file for the category. E.g. `content/category/index.md`.
3. Add the new category to the `Makefile`

[self]: https://readrust.net/
[contributing]: https://readrust.net/submit.html
[#Rust2018]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[Cobalt]: http://cobalt-org.github.io/
[install-cobalt]: http://cobalt-org.github.io/docs/install.html
