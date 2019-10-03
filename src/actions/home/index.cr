class Home::Index < BrowserAction
  include Auth::AllowGuests

  get "/" do
    recent_posts = PostQuery.new.preload_categories.recent_in_category(AllCategory.new).limit(10)
    render Categories::IndexPage, categories: CategoryQuery.new, recent_posts: recent_posts
  end
end
