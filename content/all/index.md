title: All Posts
layout: default.liquid
---

All {{ site.data.rust.posts.items | size }} posts.

<h2>
  Posts
  <a class="feedicon" href="/all/feed.rss" title="All Posts RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/all/feed.json" title="All Posts JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>


<ul>
{% for post in site.data.rust.posts.items %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
{% endfor %}
</ul>
