class Favicon::Show < BrowserAction
  include Auth::AllowGuests

  before cache_publicly(1.day)

  get "/favicon.ico" do
    file "public/favicon.ico", disposition: "inline"
  end
end
