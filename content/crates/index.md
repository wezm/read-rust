---
title: Crates
layout: default.liquid
---

Interesting new or updated crates.

<h2>
  Posts
  <a class="feedicon" href="/crates/feed.rss" title="Crates RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/crates/feed.json" title="Crates JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Crates" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
