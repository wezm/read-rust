class Categories::Show < BrowserAction
  include Auth::AllowGuests

  get "/:slug" do
    if category = CategoryQuery.new.slug(slug).first?
      html ShowPage, category: category, posts: PostQuery.new.recent_in_category(category)
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
