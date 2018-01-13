title: Read Rust
layout: default.liquid
---

[#Rust2018](/rust2018/)


{% for post in collections.posts.pages %}
#### {{post.title}}

[{{ post.title }}]({{ post.permalink }})
{% endfor %}
