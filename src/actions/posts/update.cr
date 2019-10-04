class Posts::Update < BrowserAction
  route do
    post = PostQuery.find(post_id)
    SavePost.update(post, params) do |form, post|
      if form.saved?
        flash.success = "The record has been updated"
        redirect Show.with(post.id)
      else
        flash.failure = "It looks like the form is not valid"
        render EditPage, form: form, post: post
      end
    end
  end
end
