require "markd"

class About::ShowPage < MainLayout
  quick_def page_title, "About"

  def content
    raw render_markdown(markdown_top)

    ul do
      li do
        text "Main feed (all posts): "
        a "RSS", href: "/all/feed.rss"
        text " or "
        a "JSON", href: "/all/feed.json"
      end
      text " {% for category in site.data.categories %} "
      li do
        text "{{ category.name | escape }}: "
        a "RSS", href: "{{ category.path }}feed.rss"
        text " or "
        a "JSON", href: "{{ category.path }}feed.json"
      end
      text " {% endfor %} "
    end

    raw render_markdown(markdown_bottom)
  end

  def markdown_top
    <<-MD
    Read Rust collects interesting posts related to the [Rust programming
    language][rust-lang]. It is run by [Wesley Moore][wezm] with contributions from
    the Rust community. Find me on [Twitter][@wezm] or [Mastodon][@wezm@mastodon].
    You can [support my work on Patreon][Patreon].

    Read Rust is an open source project. The [source code][source] and [issue
    tracker][issues] are hosted on GitHub.

    <h2 id="feeds">Feeds</h2>

    I am a proponent of the open web and as a result the content of Read Rust is
    available in a number of machine readable formats. There are feeds available
    for the whole site, as well as each of the categories:
    MD
  end

  def markdown_bottom
    <<-MD
    In order to discover new posts I subscribe to a lot of Rust related RSS feeds.
    The list is available in [OPML] (readily importable into [feed
    readers](#subscribe)):

    * Blog list: [OPML](/rust-blogs.opml)

    ## Social Media

    Read Rust also has social media accounts, which automatically post each newly
    added post:

    * [Mastodon]
    * [Twitter]
    * [Facebook]

    ## FAQ

    <h3 id="subscribe">How do I subscribe?</h3>

    Subscribe to [one of the feeds][feeds] in a feed reader. There are feeds for all news
    posts as well as for individual categories. Some feed readers are shown below.
    I&nbsp;use and recommend [Feedbin] + [Reeder]:

    * [Feedbin] (Web, Third party clients)
    * [Feed Wrangler](https://feedwrangler.net/) (Web & iOS)
    * [FeedReader](https://jangernert.github.io/FeedReader/) (Linux)
    * [Feedly](https://feedly.com/) (Web, Third party clients)
    * [NewsBlur](https://www.newsblur.com/) (Web, iOS & Android)
    * [Reeder] (iOS & macOS)
    * [selfoss](https://selfoss.aditu.de/) (Self-hosted)
    * [Thunderbird](https://support.mozilla.org/en-US/kb/how-subscribe-news-feeds-and-blogs) (BSD, Linux, Mac, Windows, etc.)

    Alternatively you may follow Read Rust on [Twitter][@read_rust], [Mastodon] or [Facebook].

    ### What is JSON Feed?

    A format similar to <a href="http://cyber.harvard.edu/rss/rss.html">RSS</a> and
    <a href="https://tools.ietf.org/html/rfc4287">Atom</a> but in JSON. For more
    details visit the [JSON&nbsp;Feed website][json-feed-website].

    [#Rust2018]: https://twitter.com/search?f=tweets&vertical=default&q=%23Rust2018
    [add-post]: https://github.com/wezm/read-rust/issues/new?labels=missing-post&title=Add+post&template=missing_post.md
    [call-for-posts]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
    [favicon]: https://thenounproject.com/term/book/17900
    [Feedbin]: https://feedbin.com/
    [feeds]: /about.html#feeds
    [json-feed-website]: https://jsonfeed.org/
    [Reeder]: http://reederapp.com/
    [rust-reddit]: https://www.reddit.com/r/rust/
    [@read_rust]: https://twitter.com/read_rust
    [Facebook]: https://www.facebook.com/readrust/
    [Mastodon]: https://botsin.space/@readrust

    ## Credits

    * JSON Feed icon: <https://jsonfeed.org/version/1>
    * Facebook, Mastodon, RSS, Twitter icons: [Super Tiny Icons]
    * Logo: “[Book][favicon]” by Mike Rowe, from [the Noun Project]
    * Heart icon: “[Heart]” by Mike Rowe, from [the Noun Project]
    * [Balloon.css]: Copyright (c) 2016 Claudio Holanda

    [favicon]: https://thenounproject.com/term/book/17900
    [rust-lang]: https://www.rust-lang.org/
    [wezm]: http://www.wezm.net/about/
    [source]: https://github.com/wezm/read-rust
    [issues]: https://github.com/wezm/read-rust/issues
    [@wezm]: https://twitter.com/wezm
    [Twitter]: https://twitter.com/read_rust
    [OPML]: https://en.wikipedia.org/wiki/OPML
    [@wezm@mastodon]: https://mastodon.social/@wezm
    [Mastodon]: https://botsin.space/@readrust
    [the Noun Project]: http://thenounproject.com/
    [Facebook]: https://www.facebook.com/readrust/
    [Super Tiny Icons]: https://github.com/edent/SuperTinyIcons
    [Patreon]: https://patreon.com/wezm
    [Heart]: https://thenounproject.com/search/?q=heart&creator=9861&i=372271
    [Balloon.css]: https://github.com/kazzkiq/balloon.css
    MD
  end

  def render_markdown(source)
    options = Markd::Options.new(smart: true)
    Markd.to_html(source, options)
  end
end
