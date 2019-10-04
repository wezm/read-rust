class Posts::NewPage < AdminLayout
  needs form : SavePost
  needs categories : CategoryQuery
  quick_def page_title, "New Post"

  # Query param
  # param page : Int32 = 1

  def content
    render_post_form(@form)
  end

  def render_post_form(f)
    form_for Posts::Create, class: "form-stacked" do
      mount Shared::Field.new(f.title), &.text_input(autofocus: "true")
      mount Shared::Field.new(f.author)
      mount Shared::Field.new(f.url, "URL"), &.url_input
      mount Shared::Field.new(f.twitter_url, "Twitter URL"), &.url_input
      mount Shared::Field.new(f.mastodon_url, "Fediverse URL"), &.url_input
      mount Shared::Field.new(f.summary)

      fieldset(class: "categories") do
        tag "legend" { text "Categories" }

        @categories.each_with_index do |category, i|
          # label { input[type = "checkbox", name="categories[]", value = { category.id }]; { category.name } }
          label do
            # checkbox f.categories, value: category.id
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
