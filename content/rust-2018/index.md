title: Rust 2018
layout: default.liquid
---

On 3 Jan 2018 the Rust blog put out a [call for community blog
posts][call-for-posts] that reflected on 2017 and proposed goals and
directions for Rust in 2018. Responses have flooded in across Twitter, Reddit,
and elsewhere.

<h2>
  Posts
  <a class="feedicon" href="/rust-2018/feed.rss" title="Rust 2018 RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/rust-2018/feed.json" title="Rust 2018 JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% assign post_count = 0 %}
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2018" %}
  {% assign post_count = post_count | plus: 1 %}
  {% endif %}
{% endfor %}
{{ post_count }} posts were made by the Rust community:

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Rust 2018" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>

[call-for-posts]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
