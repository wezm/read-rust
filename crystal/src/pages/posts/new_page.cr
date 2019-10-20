class Posts::NewPage < AdminLayout
  needs form : SavePost
  needs categories : Array(Category)
  quick_def page_title, "New Post"

  def content
    render_post_form(@form)
  end

  def render_post_form(f)
    form_for Posts::Create, id: "new-post-form", class: "form-stacked" do
      mount Shared::Field.new(f.title), &.text_input(attrs: [:autofocus, :required])
      mount Shared::Field.new(f.author), &.text_input(attrs: [:required])
      mount Shared::Field.new(f.url, "URL"), &.url_input(attrs: [:required])
      mount Shared::Field.new(f.twitter_url, "Twitter URL"), &.url_input
      mount Shared::Field.new(f.mastodon_url, "Fediverse URL"), &.url_input
      mount Shared::Field.new(f.summary), &.textarea(required: "required")

      fieldset(class: "categories") do
        tag "legend" { text "Categories" }

        @categories.each_with_index do |category, i|
          label do
            input type: "checkbox", name: "post_category[#{i}]:category_id", value: category.id
            text category.name
          end
        end
      end

      div class: "form-actions" do
        submit "Save", data_disable_with: "Saving..."
      end
    end
  end
end
