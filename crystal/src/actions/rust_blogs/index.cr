class RustBlogs::Index < BrowserAction
  include Auth::AllowGuests
  include Lucky::SkipRouteStyleCheck

  before cache_publicly(1.hour)

  get "/rust-blogs.opml" do
    file "public/rust-blogs.opml", content_type: "application/xml", disposition: "inline"
  end
end
