class Posts::EditPage < MainLayout
  needs form : SavePost
  needs post : Post
  quick_def page_title, "Edit Post"

  def content
    form_for Posts::Update.with(@post.id), id: "edit-post-form", class: "form-stacked" do
      mount Posts::Form.new(@form, @post)
    end
  end
end
