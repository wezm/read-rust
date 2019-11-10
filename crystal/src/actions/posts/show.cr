class Posts::Show < BrowserAction
  before cache_in_varnish(2.minutes)

  get "/posts/:post_id" do
    post = PostQuery.new.preload_post_categories.find(post_id)
    weak_etag(post.updated_at.to_unix)

    html ShowPage, post: post
  end
end
