class Posts::Form < BaseComponent
  needs form : SavePost
  needs post : Post?

  def render
    mount Shared::Field.new(@form.title), &.text_input(attrs: [:autofocus, :required])
    mount Shared::Field.new(@form.author), &.text_input(attrs: [:required])
    div class: "url-form-field" do
      mount Shared::Field.new(@form.url, "URL"), &.url_input(attrs: [:required])
      url = @form.url.value || "#"
      a href: "🡭", to: url, class: "open-url", target: "_blank"
    end
    mount Shared::Field.new(@form.twitter_url, "Twitter URL"), &.url_input
    mount Shared::Field.new(@form.mastodon_url, "Fediverse URL"), &.url_input
    mount Shared::Field.new(@form.summary), &.textarea(required: "required")
    mount Shared::Field.new(@form.tags)

    fieldset(class: "categories") do
      tag "legend" { text "Categories" }

      categories.each_with_index do |category, i|
        label do
          category_checkbox(i, category.id)
          text category.name
        end
      end
    end

    div class: "form-actions" do
      submit "Save", data_disable_with: "Saving..."
    end
  end

  private def categories : Array(Category)
    CategoryQuery.new.without_all
  end

  # FIXME: Make into a component
  private def category_checkbox(i, category_id)
    input type: "checkbox", name: "post_category[#{i}]:category_id", value: category_id, attrs: category_checkbox_attrs(@post, category_id)
  end

  private def category_checkbox_attrs(post, category_id) : Array(Symbol)
    if post
      # Using post_categories! here because in the case where the form is being re-rendered due
      # to an error on update the post_categories are not pre-loaded.
      if post.post_categories!.find { |post_category| post_category.category_id == category_id }
        [:checked]
      else
        [] of Symbol
      end
    else
      [] of Symbol
    end
  end
end
