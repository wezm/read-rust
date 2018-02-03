title: Web and Network Services
layout: default.liquid
---

All things web and Rust:

* Web applications
* Web sites
* Web browsers
* Web frameworks
* Web assembly

As well as non-web network services.

<h2>
  Posts
  <a class="feedicon" href="/rust2018/feed.rss" title="Web and Network Services RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/rust2018/feed.json" title="Web and Network Services JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "Web and Network Services" %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}</li>
  {% endif %}
{% endfor %}
</ul>
