title: Rust 2018
layout: default.liquid
---

On 3 Jan 2018 the Rust blog put out a [call for community blog
posts][call-for-posts] that reflected on 2017 and proposed goals and
directions for Rust in 2018. Responses have flooded in across Twitter, Reddit,
and elsewhere.

Here you will find the current list of posts and feeds that you can subscribe
to in order to keep up with new posts, no matter where they are published.

<nav>
  * [Subscribe](#subscribe)
  * [The Posts](#posts)
  * [FAQ](#faq)
  * [Credits](#credits)
</nav>

<a name="subscribe"></a>
## Subscribe

<div class="subscribe">
  <div class="feedicon">
    <a href="/rust2018/feed.json">
      <img src="/images/jsonfeed.png" />
      #Rust2018 JSON Feed
    </a>
  </div>

  <div class="feedicon">
    <a href="/rust2018/feed.rss">
      <img src="/images/feed-icon.svg" />
      #Rust2018 RSS Feed
    </a>
  </div>
</div>

<a name="posts"></a>
## Posts

{{ site.data.rust.posts | size }} posts have been made by the Rust community
so far:

<ul>
{% for post in site.data.rust.posts %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> by {{ post.author_name }}</li>
{% endfor %}
</ul>

<a name="faq"></a>
## FAQ

### How do I submit a new post?

Adding new posts is a manual process. I generally update the feeds once or
twice a day. If the post is tweeted with the [#Rust2018] hash tag it will be
picked up automatically when I update the feed. If the post is submitted to
[/r/rust][rust-reddit] on Reddit I should also notice it and include it.

For all other posts [create an issue on GitHub][add-post].

### How do I subscribe?

Subscribe to one of the feeds in a feed reader. Some options are shown
below. I&nbsp;use and recommend [Feedbin] + [Reeder]:

* [Feedbin] (Web, Third party clients)
* [Feed Wrangler](https://feedwrangler.net/) (Web & iOS)
* [FeedReader](https://jangernert.github.io/FeedReader/) (Linux)
* [Feedly](https://feedly.com/) (Web, Third party clients)
* [NewsBlur](https://www.newsblur.com/) (Web, iOS & Android)
* [Reeder] (iOS & macOS)
* [selfoss](https://selfoss.aditu.de/) (Self-hosted)
* [Thunderbird](https://support.mozilla.org/en-US/kb/how-subscribe-news-feeds-and-blogs) (BSD, Linux, Mac, Windows, etc.)

### What is JSON Feed?

A format similar to <a href="http://cyber.harvard.edu/rss/rss.html">RSS</a> and
<a href="https://tools.ietf.org/html/rfc4287">Atom</a> but in JSON. For more
details visit the [JSON&nbsp;Feed website][json-feed-website].

<a name="credits"></a>
## Credits

* JSON Feed Icon: <https://jsonfeed.org/version/1>
* RSS Icon: <http://www.feedicons.com/>
* favicon: “[Book][favicon]” by Mike Rowe, from [the Noun Project]

[Feedbin]: https://feedbin.com/
[Reeder]: http://reederapp.com/
[add-post]: https://github.com/wezm/read-rust/issues/new?labels=missing-post&title=Add+post&template=missing_post.md
[#Rust2018]: https://twitter.com/search?f=tweets&vertical=default&q=%23Rust2018
[call-for-posts]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
[rust-reddit]: https://www.reddit.com/r/rust/
[json-feed-website]: https://jsonfeed.org/
[favicon]: https://thenounproject.com/term/book/17900
[the Noun Project]: http://thenounproject.com/
