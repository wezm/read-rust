class RssFeed::Show < BrowserAction
  include Auth::AllowGuests
  include Categories::FindCategory

  before cache_in_varnish(2.minutes)

  get "/:slug/feed.rss" do
    unconditional_weak_etag(last_modified.to_unix)

    send_text_response(render_feed(category), "application/rss+xml", nil)
  end

  private def render_feed(category : Category)
    posts = PostQuery.new.recent_in_category(category).limit(100)
    items = posts.map do |post|
      RSS::Item.new(
        guid: RSS::Guid.new(value: post.guid.to_s, is_permalink: false),
        title: post.title,
        link: post.url,
        description: post.summary,
        author: post.author,
        pub_date: post.created_at,
      )
    end
    last_build_date = posts.map(&.created_at).max

    feed = RSS::Channel.new(
      title: "Read Rust - #{category.name}",
      description: category.description,
      link: "https://readrust.net/",
      feed_url: RssFeed::Show.with(category.slug).url,
      items: items,
      last_build_date: last_build_date,
    )

    feed.to_xml
  end

  private def last_modified
    time = PostQuery.new.last_modified_in_category(category)
    if time.nil?
      Time.utc
    else
      time
    end
  end
end
