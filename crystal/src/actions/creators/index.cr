class Creators::Index < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(5.minutes)

  get "/support" do
    weak_etag(last_modified.to_unix)

    html IndexPage, creators: CreatorQuery.new.preload_tags
  end

  private def last_modified
    time = CreatorQuery.new.updated_at.select_max
    if time.nil?
      Time.utc
    else
      time
    end
  end
end
