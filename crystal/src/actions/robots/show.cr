class Robots::Show < BrowserAction
  include Auth::AllowGuests

  before cache_publicly(1.hour)

  get "/robots.txt" do
    plain_text "User-Agent: *
Disallow:
Sitemap: #{Sitemap::Show.url}
"
  end
end
