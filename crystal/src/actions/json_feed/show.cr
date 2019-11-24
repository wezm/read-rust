class JsonFeed::Show < BrowserAction
  include Auth::AllowGuests
  include Categories::FindCategory

  before cache_in_varnish(2.minutes)

  get "/:slug/feed.json" do
    unconditional_weak_etag(last_modified.to_unix)

    json ShowSerializer.new(category)
  end

  private def last_modified
    PostQuery.new.last_modified_in_category(category)
  end
end
