title: Welcome
layout: default.liquid
---

Read Rust collects interesting posts about or related to the [Rust programming
language][rust-lang].

## Sections

* [Rust 2018](/rust2018/)
* [Embedded](/embedded/)
* [Web and Network Services](/net/)
* [Performance](/performance/)
* [Crypto](/crypto/) ?
* [Operating Systems](/os/)
* [Computer Science](/cs/) — covering data sctructures, algorithms, etc.
* [Community](/community/)
* [Talks and Presentations](/talks/)

{% for post in collections.posts.pages %}
#### {{post.title}}

[{{ post.title }}]({{ post.permalink }})
{% endfor %}

[rust-lang]: https://www.rust-lang.org/
