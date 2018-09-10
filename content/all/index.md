title: All Posts
layout: default.liquid
---

All {{ site.data.rust.posts.items | size }} posts.

<h2>
  Posts
  <a class="feedicon" href="/all/feed.rss" title="All Posts RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/all/feed.json" title="All Posts JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>


<ul>
{% for post in site.data.rust.posts.items %}
  <li><a href="{{ post.url }}">{{ post.title | escape }}</a> by {{ post.author.name | escape }}</li>
{% endfor %}
</ul>
