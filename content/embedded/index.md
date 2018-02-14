title: Embedded
layout: default.liquid
---

Posts about using Rust on embedded systems. Including microcontrollers,
IoT, and devices.

<h2>
  Posts
  <a class="feedicon" href="/embedded/feed.rss" title="Embedded RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/embedded/feed.json" title="Embedded JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Embedded" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
