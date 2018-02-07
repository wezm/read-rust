title: Home
layout: default.liquid
---

Read Rust collects interesting posts related to the [Rust
programming&nbsp;language][rust-lang].

For updates [subscribe to a feed][feeds], or follow [@read_rust] on Twitter.

## Sections

New posts are added to one or more of the following sections:

<ul>
<li><a href="/all/">All Posts</a></li>
{% for category in site.data.categories %}
<li><a href="{{ category.path }}">{{ category.name }}</a> — {{ category.description }}</li>
{% endfor %}
</ul>
<!-- * [Community](/community/) — regarding the Rust community. -->
<!-- * [Crypto](/crypto/) ? -->
<!-- * [DevOps](/devops/) -->
<!-- * [Games](/games/) -->
<!-- * [Talks and Presentations](/talks/) -->

<h2>
  Recent Posts
  <a class="feedicon" href="/all/feed.rss" title="Read Rust RSS Feed">
    <img src="/images/feed-icon.svg" />
  </a>
  <a class="feedicon" href="/all/feed.json" title="Read Rust JSON Feed">
    <img src="/images/jsonfeed.png" />
  </a>
</h2>

<ul>
{% assign count = 0 %}
{% for post in site.data.rust.posts.items %}
  {% assign count = count | plus: 1 %}
<li>
  <a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author.name }}
  in {% for tag in post.tags %}<a href="/{{ tag | downcase | replace: " ", "-" }}/">{{ tag }}</a>{% unless forloop.last %}, {% endunless %}{% endfor %}
</li>
  {% if count >= 10 %}{% break %}{% endif %}
{% endfor %}
</ul>

[View all posts](/all/)

[feeds]: /about.html#feeds
[rust-lang]: https://www.rust-lang.org/
[@read_rust]: https://twitter.com/read_rust
