title: Home
layout: default.liquid
---

Read Rust collects interesting posts related to the [Rust
programming&nbsp;language][rust-lang].

For updates [subscribe to a feed][feeds], or follow [@read_rust] on Twitter.

## Sections

New posts are added to one or more sections.

* [All Posts](/all/)
* [Crates](/crates/) — notable new crates or updates.
* [Embedded](/embedded/) — Rust on microcontrollers, IoT, devices.
* [Performance](/performance/) — optimisation, benchmarks, etc.
* [Rust 2018](/rust-2018/) — hopes and dreams for Rust in 2018
* [Tools and Applications](/tools-and-applications/) — command line tools and GUI applications
* [Web and Network Services](/web-and-network-services/) — web applications, web assembly, network daemons, etc.
<!-- * [Community](/community/) — regarding the Rust community. -->
<!-- * [Computer Science](/cs/) — covering data structures, algorithms, etc. -->
<!-- * [Crypto](/crypto/) ? -->
<!-- * [DevOps](/devops/) -->
<!-- * [Games](/games/) -->
<!-- * [Talks and Presentations](/talks/) -->
<!-- * [Operating Systems](/operating-systems/) — Using Rust to build all or part of an operating system. -->

<h2>
  Recent Posts
  <a class="feedicon" href="/rust2018/feed.rss" title="Read Rust RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/rust2018/feed.json" title="Read Rust JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% assign count = 0 %}
{% for post in site.data.rust.posts.items %}
  {% assign count = count | plus: 1 %}
<li>
  <a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}
  in {% for tag in post.tags %}<a href="/{{ tag | downcase | replace: " ", "-" }}/">{{ tag }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}
</li>
  {% if count >= 10 %}{% break %}{% endif %}
{% endfor %}
</ul>

[View all posts](/all/)

[feeds]: /about.html#feeds
[rust-lang]: https://www.rust-lang.org/
[@read_rust]: https://twitter.com/read_rust
