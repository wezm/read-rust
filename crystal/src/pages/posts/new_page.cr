class Posts::NewPage < AdminLayout
  needs form : SavePost
  quick_def page_title, "New Post"

  def content
    form_for Posts::Create, id: "new-post-form", class: "form-stacked" do
      mount Posts::Form.new(@form, post: nil)
    end
  end
end
