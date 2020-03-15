class Tags::Show < BrowserAction
  include Auth::AllowGuests

  FEED_LIMIT = 100

  before cache_in_varnish(2.minutes)

  get "/tags/:raw_tag_name" do
    tag_name = TagName.new(raw_tag_name)
    tag = TagQuery.new.name(tag_name.name).first
    posts = PostQuery.new.preload_post_categories.preload_tags.where_post_tags(PostTagQuery.new.tag_id(tag.id)).created_at.desc_order

    case tag_name.format
    when ""
      respond_with_html(tag, posts)
    when ".rss"
      respond_with_rss(tag, posts)
    when ".json"
      respond_with_json(tag, posts)
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end

  private def last_modified(tag)
    time = PostQuery.new.where_post_tags(PostTagQuery.new.tag_id(tag.id)).updated_at.select_max
    if time.nil?
      Time.utc
    else
      time
    end
  end

  private def respond_with_html(tag : Tag, posts : PostQuery)
    weak_etag(last_modified(tag).to_unix)

    html ShowPage, tag: tag, posts: posts
  end

  private def respond_with_rss(tag : Tag, posts : PostQuery)
    unconditional_weak_etag(last_modified(tag).to_unix)

    send_text_response(render_rss(tag, posts.limit(FEED_LIMIT)), "application/rss+xml", nil)
  end

  private def respond_with_json(tag : Tag, posts : PostQuery)
    unconditional_weak_etag(last_modified(tag).to_unix)

    json render_json(tag, posts.limit(FEED_LIMIT))
  end

  private def render_rss(tag : Tag, posts : PostQuery)
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
      title: "Read Rust - #{tag.name}",
      description: "Posts tagged '#{tag.name}' on Read Rust",
      link: "https://readrust.net/",
      feed_url: Tags::Show.with(tag.name + ".rss").url,
      items: items,
      last_build_date: last_build_date,
    )

    feed.to_xml
  end

  private def render_json(tag : Tag, posts : PostQuery)
    {
      version:       "https://jsonfeed.org/version/1",
      title:         "Read Rust - #{tag.name}",
      home_page_url: "https://readrust.net/",

      feed_url: Tags::Show.with(tag.name + ".json").url,
      description: "Posts tagged '#{tag.name}' on Read Rust",
      author:        {
        name: "Wesley Moore",
        url:  "https://www.wezm.net/",
      },
      items: posts.map { |post| JsonFeed::PostSerializer.new(post) },
    }
  end
end
