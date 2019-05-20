---
title: Community
layout: default.liquid
---

Initiatives in the Rust community.

<h2>
  Posts
  <a class="feedicon" href="/community/feed.rss" title="Community RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/community/feed.json" title="Community JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Community" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
