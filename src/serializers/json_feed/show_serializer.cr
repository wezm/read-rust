class JsonFeed::ShowSerializer < Lucky::Serializer
  def initialize(@category : AllCategory | Category)
  end

  def render
    posts = PostQuery.new.preload_categories.recent_in_category(@category).limit(100)
    {
      version:       "https://jsonfeed.org/version/1",
      title:         "Read Rust",
      home_page_url: "https://readrust.net/",
      feed_url:      "https://readrust.net/all/feed.json",
      description:   "Rust related posts from around the internet.",
      author:        {
        name: "Wesley Moore",
        url:  "https://www.wezm.net/",
      },
      items: posts.map { |post| PostSerializer.new(post) },
    }
  end
end
