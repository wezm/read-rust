# Read Rust

Source code to [readrust.net][self]. A news aggregator for Rust news.
This repo contains the source to the website and tools for updating the feeds.

[![Build Status](https://travis-ci.org/wezm/read-rust.svg?branch=master)](https://travis-ci.org/wezm/read-rust)

## Contributing

Check out the [Submission page on the website][contributing] for info on
submitting a post.

## Development

First up: I'm sorry 😭

_I'm aware this involves a lot of dependencies. I had started building this
version of the site in Rust but paused that effort as at Oct 2019 the web and
async state of Rust was very much in flux. I picked Lucky because it was a
batteries included web framework backed by an ergonomic, statically typed
language that did not require a large runtime. In some parts I'm still using
Rust since I already had the code/it was easier for me. Eventually I hope to
shift to an all Rust code base but today is not that day._

My development environment for the site is Arch Linux and it generally makes
the experience straightforward. The instructions below are for Arch, adjust
accordingly for other systems.

### Prerequisites

* [Crystal] 0.31.1
* [Lucky CLI](https://aur.archlinux.org/packages/lucky)
  * [node] and [yarn] (for assets)
  * [overmind] (process runner to make development nicer)
* [Rust] >= 1.38.0
* [PostgreSQL] (9, 10, or 11 should be fine. I develop on 11, CI runs 9)
* [Chromium] (for running [flow tests])

The package list on Arch is something like this.

    rustup crystal shards nodejs yarn postgresql postgresql-libs chromium gcc pkgconf sudo make

Plus from the AUR:

* [lucky]
* [overmind] or [overmind-bin]

Additionally, due to [limitations in the Crystal compiler](https://github.com/crystal-lang/crystal/issues/7514)
you need to build and install my little [striptags library]:

    git clone https://github.com/wezm/aur
    cd aur/libstriptags
    makepkg -si

If you've never set up PostgreSQL before, you will need to follow the
[initial configuration](https://wiki.archlinux.org/index.php/PostgreSQL#Initial_configuration)
steps. For local development with PostgreSQL it's convienient to have a role with the
same name as your username:

    sudo -u postgres createuser --interactive $USER
    Shall the new role be a superuser? (y/n) y

### Building and Running

Clone the repo if you have not done so already:

    git clone https://github.com/wezm/read-rust.git
    cd read-rust

Create `.env` file with configuration. You only need to change, `DATABASE_URL`
and `TEST_DATABASE_URL` to match the user your created above.

    cp .env.sample .env
    $EDITOR .env

Set up the database and asset pipeline (only need to do this once):

    cd crystal
    script/setup

Run the development server:

    lucky dev

After it compiles the site should now be accessible at: <http://127.0.0.1:3001/>

### Importing From Version 1

    cd crystal
    lucky import_posts ../content/_data/rust/posts.json ../content/_data/{tweeted,tooted}.json
    lucky import_creators ../content/_data/creators.yaml

### Website

The website is built with [Cobalt]. After [installing Cobalt][install-cobalt]
the site can be built by running `make`.

### Tools

The tools are mostly written in Rust, so `cargo build --release` will build
them. The tools themselves are:

* `add-url` add a new entry to `feed.json`.
* `generate-rss` generates `feed.rss`, and the cobalt data from `feed.json`.
* `opml2json` converts subscriptions downloaded from Feedbin into JSON.

Running `make` will build the tools and generate the site content.

## Notes

### Adding a New Category

1. Add an entry to `content/_data/categories.json`
2. Add a new content directory and index file for the category. E.g. `content/category/index.md`.
3. Add the new category to the `Makefile`

### Resize Avatars

    cd content/images/u
    convert *.png *.jpg -set filename:name '%t' -resize 100\> -quality 60 'thumb/%[filename:name].jpg'

### Updating OPML

Download subscriptions from [Feedbin](https://feedbin.com/settings/import_export), then:

    ./script/opml2json ~/Downloads/subscriptions.xml > content/_data/rust/blogs.json
    make
    xmllint public/rust-blogs.opml

Some manual tweaks to the JSON might be needed.

[self]: https://readrust.net/
[contributing]: https://readrust.net/submit.html
[#Rust2018]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[Cobalt]: https://cobalt-org.github.io/
[install-cobalt]: https://cobalt-org.github.io/docs/install
