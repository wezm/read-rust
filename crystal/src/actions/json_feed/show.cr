class JsonFeed::Show < BrowserAction
  include Auth::AllowGuests
  include Categories::FindCategory

  before cache_in_varnish(2.minutes)

  get "/:slug/feed.json" do
    unconditional_weak_etag(last_modified.to_unix)

    json ShowSerializer.new(category)
  end

  private def last_modified
    time = PostQuery.new.last_modified_in_category(category)
    if time.nil?
      Time.utc
    else
      time
    end
  end
end
