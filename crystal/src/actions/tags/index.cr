class Tags::Index < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(2.minutes)

  get "/tags" do
    html IndexPage, tags: TagQuery.with_posts
  end
end
