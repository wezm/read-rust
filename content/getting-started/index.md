title: Getting Started
layout: default.liquid
---

Introductory posts, tutorials and guides to getting started with Rust.

<h2>
  Posts
  <a class="feedicon" href="/getting-started/feed.rss" title="Getting Started RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/getting-started/feed.json" title="Getting Started JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Getting Started" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
