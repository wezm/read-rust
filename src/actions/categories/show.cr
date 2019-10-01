class Categories::Show < BrowserAction
  include Auth::AllowGuests

  get "/:slug" do
    if category = CategoryQuery.new.slug(slug).first?
      render ShowPage, category: category
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
