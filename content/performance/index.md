title: Performance
layout: default.liquid
---

All things high performance Rust.

<h2>
  Posts
  <a class="feedicon" href="/performance/feed.rss" title="Performance RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/performance/feed.json" title="Performance JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Performance" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
