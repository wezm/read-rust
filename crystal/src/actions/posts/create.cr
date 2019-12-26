class Posts::Create < BrowserAction
  route do
    response = nil
    AppDatabase.transaction do
      tx_result = nil
      SavePost.create(params) do |form, post|
        if post && save_categories(post) && save_tags(post, form)
          flash.success = "The record has been saved"
          response = redirect Show.with(post.id)
          tx_result = true
        else
          flash.failure = "Unable to create Post"
          response = html NewPage, form: form
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

  private def save_tags(post, form) : Bool
    tags = (form.tags.value || "").strip.downcase.split(/\s+/, remove_empty: true).uniq
    tags.each do |tag_name|
      tag = TagQuery.new.name(tag_name).first?
      if tag.nil?
        tag = SaveTag.create!(name: tag_name)
      end

      SavePostTag.create!(post_id: post.id, tag_id: tag.id)
    end

    true
  rescue Avram::InvalidOperationError
    false
  end
end
