title: Operating Systems
layout: default.liquid
---

Posts about using Rust to build all or part of an operating system.

<h2>
  Posts
  <a class="feedicon" href="/operating-systems/feed.rss" title="Operating Systems RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/operating-systems/feed.json" title="Operating Systems JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Operating Systems" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
