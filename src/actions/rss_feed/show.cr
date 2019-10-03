class RssFeed::Show < BrowserAction
  include Auth::AllowGuests

  get "/:slug/feed.rss" do
    xml render_feed(category)
  end

  private def render_feed(category : AllCategory | Category)
    posts = category.recent_posts
    items = posts.map do |post|
      RSS::Item.new(
        guid: RSS::Guid.new(value: post.guid.hexstring, is_permalink: false),
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
      description: "#{category.name} posts on Read Rust",
      link: "https://readrust.net/",
      feed_url: "https://readrust.net/#{category.slug}/feed.rss",
      items: items,
      last_build_date: last_build_date,
    )

    feed.to_xml
  end

  private def category
    if slug == "all"
      AllCategory.new
    elsif category = CategoryQuery.new.slug(slug).first?
      category
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
