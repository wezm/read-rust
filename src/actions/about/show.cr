class About::Show < BrowserAction
  include Auth::AllowGuests

  get "/about" do
    html ShowPage, categories: CategoryQuery.new
  end
end
