---
title: Rust 2019
layout: default.liquid
---

After the success of the [2018 call for posts][call-for-posts] the [call was
put out again for the Rust community to write about their ideas for
2019][call-for-posts-2019] and the next edition.

<h2>
  Posts
  <a class="feedicon" href="/rust-2019/feed.rss" title="Rust 2019 RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/rust-2019/feed.json" title="Rust 2019 JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% assign post_count = 0 %}
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2019" %}
  {% assign post_count = post_count | plus: 1 %}
  {% endif %}
{% endfor %}
{{ post_count }} posts were made by the Rust community:

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2019" %}
  <li><a href="{{ post.url }}">{{ post.title | escape }}</a> by {{ post.author.name | escape }}</li>
  {% endif %}
{% endfor %}
</ul>

[call-for-posts]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[call-for-posts-2019]: https://blog.rust-lang.org/2018/12/06/call-for-rust-2019-roadmap-blogposts.html
