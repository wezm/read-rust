---
title: Rust 2020
layout: default.liquid
---

> We are accepting ideas about almost anything having to do with
> Rust: language features, tooling needs, community
> programs, ecosystem needs... if it's related to Rust, we want to hear about
> it.
>
> One big question for this year: will there be a Rust 2021 edition? If so,
> 2020 would be the year to do a lot of associated work and plan the details.
> What would the edition's theme be?

&mdash; [A call for blogs 2020][call-for-posts-2020]

<h2>
  Posts
  <a class="feedicon" href="/rust-2020/feed.rss" title="Rust 2020 RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/rust-2020/feed.json" title="Rust 2020 JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% assign post_count = 0 %}
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2020" %}
  {% assign post_count = post_count | plus: 1 %}
  {% endif %}
{% endfor %}
{{ post_count }} posts have been made by the Rust community:

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2020" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}

[call-for-posts-2020]: https://blog.rust-lang.org/2019/10/29/A-call-for-blogs-2020.html
