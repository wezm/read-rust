---
title: Security
layout: default.liquid
---

Posts about writing secure software, cryptography, etc.

<h2>
  Posts
  <a class="feedicon" href="/security/feed.rss" title="Security RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/security/feed.json" title="Security JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Security" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
