title: Computer Science
layout: default.liquid
---

Algorithms, data structures, safety.

<h2>
  Posts
  <a class="feedicon" href="/computer-science/feed.rss" title="Computer Science RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/computer-science/feed.json" title="Computer Science JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Computer Science" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
