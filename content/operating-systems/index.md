title: Operating Systems
layout: default.liquid
---

Posts about using Rust to build all or part of an operating system.

<h2>
  Posts
  <a class="feedicon" href="/rust2018/feed.rss" title="Operating Systems RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/rust2018/feed.json" title="Operating Systems JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Operating Systems" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
