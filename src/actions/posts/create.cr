class Posts::Create < BrowserAction
  route do
    response = nil
    AppDatabase.transaction do
      SavePost.create(params) do |form, post|
        # TODO: Require at least one category
        response = if post && save_categories(post)
                     flash.success = "The record has been saved"
                     redirect Show.with(post.id)
                   else
                     flash.failure = "Unable to create Post"
                     html NewPage, form: form, categories: CategoryQuery.new
                   end
      end

      true
    end

    response.not_nil!
  end

  private def save_categories(post) : Bool
    params.many_nested(:post_category).each do |category_params|
      SavePostCategory.create!(category_id: category_params["category_id"].to_i64, post_id: post.id)
    end

    true
  end
end
