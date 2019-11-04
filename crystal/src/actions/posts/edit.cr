class Posts::Edit < BrowserAction
  route do
    post = PostQuery.new.preload_post_categories.find(post_id)
    html EditPage,
      form: SavePost.new(post),
      post: post
  end
end
