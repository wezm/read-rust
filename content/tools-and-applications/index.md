title: Tools and Applications
layout: default.liquid
---

Command line tools and GUI applications built with Rust or built for
Rust.

<h2>
  Posts
  <a class="feedicon" href="/tools-and-applications/feed.rss" title="Tools and Applications RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/tools-and-applications/feed.json" title="Tools and Applications JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Tools and Applications" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
