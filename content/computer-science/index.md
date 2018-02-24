title: Computer Science
layout: default.liquid
---

Algorithms, data structures, safety.

<h2>
  Posts
  <a class="feedicon" href="/computer-science/feed.rss" title="Computer Science RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/computer-science/feed.json" title="Computer Science JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Computer Science" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
