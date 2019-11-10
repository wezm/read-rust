class Submit::Show < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(2.minutes)

  get "/submit" do
    html ShowPage
  end
end
