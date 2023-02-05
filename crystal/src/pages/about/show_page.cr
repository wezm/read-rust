require "markd"

class About::ShowPage < MainLayout
  include Page::RenderMarkdown

  needs categories : CategoryQuery
  quick_def page_title, "About"
  quick_def page_description, ""

  def content
    raw render_markdown(markdown_top)

    ul do
      @categories.each do |category|
        if category.all?
          feed_links(category, "Main feed (all posts)")
        else
          feed_links(category)
        end
      end
    end

    raw render_markdown(markdown_bottom)
  end

  def feed_links(category, description = category.name)
    li do
      text "#{description}: "
      link "RSS", to: RssFeed::Show.with(category.slug)
      text " or "
      link "JSON", to: JsonFeed::Show.with(category.slug)
    end
  end

  def markdown_top
    <<-MD
    Read Rust collects interesting posts related to the [Rust programming
    language][rust-lang]. It is run by [Wesley Moore][wezm] with contributions from
    the Rust community. Find me on [Twitter][@wezm] or [Mastodon][@wezm@mastodon].
    You can [support my work via GitHub Sponsors][sponsor].

    Read Rust is an open source project. The [source code][source] and [issue
    tracker][issues] are hosted on GitHub.

    <h2 id="feeds">Feeds</h2>

    I am a proponent of the open web and as a result the content of Read Rust is
    available in a number of machine readable formats. There are feeds available
    for the whole site, as well as each of the categories:

    [rust-lang]: https://www.rust-lang.org/
    [wezm]: https://www.wezm.net/v2/about/
    [@wezm]: https://twitter.com/wezm
    [@wezm@mastodon]: https://mastodon.decentralised.social/@wezm
    [sponsor]: https://github.com/sponsors/wezm
    [source]: https://github.com/wezm/read-rust
    [issues]: https://github.com/wezm/read-rust/issues
    MD
  end

  def markdown_bottom
    <<-MD
    In order to discover new posts I subscribe to a lot of Rust related RSS feeds.
    The list is available in [OPML] (readily importable into [feed
    readers](#subscribe)):

    * Blog list: [OPML](#{RustBlogs::Index.path})

    ## Social Media

    Read Rust also has social media accounts, which automatically post each newly
    added post:

    * [Mastodon]
    * <del>[Twitter]</del> new posts are no longer posted to Twitter because it
      started charging for API access.
    * [Facebook]

    ## FAQ

    <h3 id="subscribe">How do I subscribe?</h3>

    Subscribe to [one of the feeds](#{About::Show.with(anchor: "feeds").path}) in a feed reader. There are feeds for all news
    posts as well as for individual categories. Some feed readers are shown below.
    I&nbsp;use and recommend [Feedbin] + [Reeder]:

    * [Feedbin] (Web, Third party clients)
    * [NewsFlash](https://apps.gnome.org/app/com.gitlab.newsflash/) (Linux, BSD)
    * [Feedly](https://feedly.com/) (Web, Third party clients)
    * [NewsBlur](https://www.newsblur.com/) (Web, iOS & Android)
    * [Reeder] (iOS & macOS)
    * [selfoss](https://selfoss.aditu.de/) (Self-hosted)
    * [Thunderbird](https://support.mozilla.org/en-US/kb/how-subscribe-news-feeds-and-blogs) (BSD, Linux, Mac, Windows, etc.)

    Alternatively you may follow Read Rust on <del>[Twitter][@read_rust]</del>, [Mastodon] or [Facebook].

    ### What is JSON Feed?

    A format similar to <a href="http://cyber.harvard.edu/rss/rss.html">RSS</a> and
    <a href="https://tools.ietf.org/html/rfc4287">Atom</a> but in JSON. For more
    details visit the [JSON&nbsp;Feed website][json-feed-website].

    [#Rust2018]: https://twitter.com/search?f=tweets&vertical=default&q=%23Rust2018
    [add-post]: https://github.com/wezm/read-rust/issues/new?labels=missing-post&title=Add+post&template=missing_post.md
    [call-for-posts]: https://blog.rust-lang.org/2018/01/03/new-years-rust-a-call-for-community-blogposts.html
    [favicon]: https://thenounproject.com/term/book/17900
    [Feedbin]: https://feedbin.com/
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
    [Twitter]: https://twitter.com/read_rust
    [OPML]: https://en.wikipedia.org/wiki/OPML
    [Mastodon]: https://botsin.space/@readrust
    [the Noun Project]: http://thenounproject.com/
    [Facebook]: https://www.facebook.com/readrust/
    [Super Tiny Icons]: https://github.com/edent/SuperTinyIcons
    [Heart]: https://thenounproject.com/search/?q=heart&creator=9861&i=372271
    [Balloon.css]: https://github.com/kazzkiq/balloon.css
    MD
  end
end
