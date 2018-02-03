title: News
layout: default.liquid
---

{% for post in collections.posts.pages %}
* [{{ post.title }}]({{ post.permalink }})
{% endfor %}
