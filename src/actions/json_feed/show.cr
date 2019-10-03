class JsonFeed::Show < BrowserAction
  include Auth::AllowGuests
  include Categories::FindCategory

  get "/:slug/feed.json" do
    json ShowSerializer.new(category)
  end
end
