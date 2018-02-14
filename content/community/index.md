title: Community
layout: default.liquid
---

Community

<h2>
  Posts
  <a class="feedicon" href="/community/feed.rss" title="Community RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/community/feed.json" title="Community JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Community" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
