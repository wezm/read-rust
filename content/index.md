title: Welcome
layout: default.liquid
---

Read Rust collects interesting posts about or related to the [Rust programming
language][rust-lang].

## Sections

* [Community](/community/)
* [Computer Science](/cs/) — covering data structures, algorithms, etc.
* [Crates and Libraries](/crates/)
* [Crypto](/crypto/) ?
* [DevOps](/devops/)
* [Embedded](/embedded/)
* [Games](/games/)
* [Operating Systems](/os/)
* [Performance](/performance/)
* [Rust 2018](/rust2018/)
* [Talks and Presentations](/talks/)
* [Tools and Applications](/tools/) — Command line tools and applications
* [Web and Network Services](/net/)

## Latest Blog Post

{% assign latest_post = collections.posts.pages | first %}
[{{ latest_post.title }}]({{ latest_post.permalink }})

{{ latest_post.excerpt }}

[Continue reading]({{ latest_post.permalink }})

[rust-lang]: https://www.rust-lang.org/
