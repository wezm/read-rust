class Posts::Edit < BrowserAction
  route do
    post = PostQuery.new.preload_post_categories.preload_tags.find(post_id)
    form = SavePost.new(post)
    form.tags.value = post.tags.map(&.name).join(" ")

    html EditPage,
      form: form,
      post: post
  end
end
