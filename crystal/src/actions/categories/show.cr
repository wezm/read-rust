class Categories::Show < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(1.minute)

  get "/:slug" do
    if category = CategoryQuery.new.slug(slug).first?
      weak_etag(last_modified(category).to_unix)

      html ShowPage, category: category, posts: PostQuery.new.preload_tags.recent_in_category(category)
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end

  private def last_modified(category)
    PostQuery.new.last_modified_in_category(category)
  end
end
