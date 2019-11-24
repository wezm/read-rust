class JsonFeed::ShowSerializer < BaseSerializer
  def initialize(@category : Category)
  end

  def render
    posts = PostQuery.new.preload_post_categories.recent_in_category(@category).limit(100)
    {
      version:       "https://jsonfeed.org/version/1",
      title:         "Read Rust - #{@category.name}",
      home_page_url: "https://readrust.net/",

      feed_url:      JsonFeed::Show.with(@category.slug).url,
      description:   @category.description,
      author:        {
        name: "Wesley Moore",
        url:  "https://www.wezm.net/",
      },
      items: posts.map { |post| PostSerializer.new(post) },
    }
  end
end
