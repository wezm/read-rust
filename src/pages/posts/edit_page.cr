class Posts::EditPage < MainLayout
  needs form : SavePost
  needs post : Post
  quick_def page_title, "Edit Post"

  def content
    h1 "Edit"
    render_post_form(@form)
  end

  def render_post_form(f)
    form_for Posts::Update.with(@post.id) do
      mount Shared::Field.new(f.title), &.text_input(autofocus: "true")
      # mount Shared::Field.new(f.hashtag)
      # mount Shared::Field.new(f.slug)
      # mount Shared::Field.new(f.description)

      submit "Update", data_disable_with: "Updating..."
    end
  end
end
