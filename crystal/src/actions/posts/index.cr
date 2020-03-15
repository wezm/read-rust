class Posts::Index < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(1.minute)

  get "/all" do
    weak_etag(last_modified.to_unix)

    html Posts::IndexPage, posts: PostQuery.new.created_at.desc_order
  end

  private def last_modified : Time
    time = PostQuery.new.updated_at.select_max
    if time.nil?
      Time.utc
    else
      time
    end
  end
end
