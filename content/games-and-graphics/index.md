title: Games and Graphics
layout: default.liquid
---

Building games with Rust and other graphics related work.

<h2>
  Posts
  <a class="feedicon" href="/games-and-graphics/feed.rss" title="Games and Graphics RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/games-and-graphics/feed.json" title="Games and Graphics JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Games and Graphics" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
