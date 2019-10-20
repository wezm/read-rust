class Posts::Create < BrowserAction
  route do
    response = nil
    AppDatabase.transaction do
      tx_result = nil
      SavePost.create(params) do |form, post|
        if post && save_categories(post)
          flash.success = "The record has been saved"
          response = redirect Show.with(post.id)
          tx_result = true
        else
          flash.failure = "Unable to create Post"
          response = html NewPage, form: form, categories: CategoryQuery.new.without_all
          tx_result = AppDatabase.rollback
        end
      end

      tx_result.not_nil!
    end

    response.not_nil!
  end

  private def save_categories(post) : Bool
    category_params = params.many_nested(:post_category)
    return false if category_params.empty?
    category_params.each do |category_params|
      SavePostCategory.create!(category_id: category_params["category_id"].to_i16, post_id: post.id)
    end

    true
  rescue Lucky::MissingNestedParamError
    false
  end
end
