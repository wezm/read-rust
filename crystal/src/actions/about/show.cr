class About::Show < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(2.minutes)

  get "/about" do
    html ShowPage, categories: CategoryQuery.new
  end
end
