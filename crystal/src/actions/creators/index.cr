class Creators::Index < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(5.minutes)

  get "/support" do
    weak_etag(last_modified.to_unix)

    html IndexPage, creators: CreatorQuery.new.preload_tags
  end

  private def last_modified
    CreatorQuery.new.updated_at.select_max
  end
end
