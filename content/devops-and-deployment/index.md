title: DevOps and Deployment
layout: default.liquid
---

Posts about getting Rust to production.

<h2>
  Posts
  <a class="feedicon" href="/devops-and-deployment/feed.rss" title="DevOps and Deployment RSS Feed">
    <img src="/images/rss.svg" />
  </a>
  <a class="feedicon" href="/devops-and-deployment/feed.json" title="DevOps and Deployment JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

{% for post in site.data.rust.posts.items %}
  {% if post.tags contains "DevOps and Deployment" %}
  {% include "post_excerpt.liquid" %}
  {% endif %}
{% endfor %}
