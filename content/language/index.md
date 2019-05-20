---
title: Language
layout: default.liquid
---

General posts about the Rust programming language.

<h2>
  Posts
  <a class="feedicon" href="/language/feed.rss" title="Language RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/language/feed.json" title="Language JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Language" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
