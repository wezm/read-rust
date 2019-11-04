class Posts::Update < BrowserAction
  route do
    post = PostQuery.new.preload_post_categories.find(post_id)
    existing_ids = post.post_categories.map(&.category_id).to_set
    response = nil

    AppDatabase.transaction do
      tx_result = nil
      SavePost.update(post, params) do |form, post|
        if post && save_categories(post, existing_ids)
          flash.success = "The post has been updated"
          response = redirect Show.with(post.id)
          tx_result = true
        else
          flash.failure = "Unable to update Post"
          response = html EditPage, form: form, post: post
          tx_result = AppDatabase.rollback
        end
      end

      tx_result.not_nil!
    end

    response.not_nil!
  end

  private def save_categories(post, existing_ids) : Bool
    category_params = params.many_nested(:post_category)
    return false if category_params.empty?

    selected_ids = category_params.map do |category_params|
      category_params["category_id"].to_i16
    end.to_set
    new_ids = selected_ids - existing_ids

    # Create new ones
    new_ids.each do |category_id|
      SavePostCategory.create!(category_id: category_id, post_id: post.id)
    end

    # Delete any other remaining old ones
    PostCategoryQuery.new.post_id(post.id).category_id.not.in(selected_ids).delete

    true
  rescue Lucky::MissingNestedParamError
    false
  end
end
