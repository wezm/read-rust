class Home::Index < BrowserAction
  include Auth::AllowGuests

  get "/" do
    recent_posts = PostQuery.new.preload_post_categories.recent_in_category(CategoryQuery.new.slug("all").first).limit(10)
    html Categories::IndexPage, categories: CategoryQuery.new, recent_posts: recent_posts
  end
end
