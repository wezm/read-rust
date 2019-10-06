class Robots::Show < BrowserAction
  include Auth::AllowGuests

  get "/robots.txt" do
    plain_text "User-Agent: *
Disallow:
Sitemap: #{Sitemap::Show.url}
"
  end
end
