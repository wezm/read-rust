class Home::Index < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(1.minute)

  get "/" do
    category = CategoryQuery.new.slug("all").first
    recent_posts = PostQuery.new.preload_post_categories.recent_in_category(category).limit(10)
    weak_etag(last_modified.to_unix)

    html Categories::IndexPage, categories: CategoryQuery.new.without_all, recent_posts: recent_posts
  end

  private def last_modified
    time = PostQuery.new.updated_at.select_max
    if time.nil?
      Time.utc
    else
      time
    end
  end
end
