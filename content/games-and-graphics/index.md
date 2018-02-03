title: Games and Graphics
layout: default.liquid
---

Building games with Rust and other graphics related work.

<h2>
  Posts
  <a class="feedicon" href="/games-and-graphics/feed.rss" title="Games and Graphics RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/games-and-graphics/feed.json" title="Games and Graphics JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Games and Graphics" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
