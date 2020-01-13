class Posts::Update < BrowserAction
  route do
    post = PostQuery.new.preload_post_categories.find(post_id)
    existing_category_ids = post.post_categories.map(&.category_id).to_set
    response = nil

    AppDatabase.transaction do
      tx_result = nil
      SavePost.update(post, params) do |form, post|
        if post && save_categories(post, existing_category_ids) && save_tags(post, form, PostTagQuery.new.post_id(post.id).preload_tag)
          flash.success = "The post has been updated"
          response = redirect Show.with(post.id)
          refresh_full_text_index
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

  private def save_tags(post, form, existing_post_tags) : Bool
    tags = (form.tags.value || "").strip.downcase.split(/\s+/, remove_empty: true).to_set

    keep, delete = existing_post_tags.partition { |post_tag| tags.includes?(post_tag.name) }
    create = tags - keep.map(&.name)

    create.each do |tag_name|
      tag = TagQuery.new.name(tag_name).first?
      if tag.nil?
        tag = SaveTag.create!(name: tag_name)
      end

      SavePostTag.create!(post_id: post.id, tag_id: tag.id)
    end

    PostTagQuery.new.id.in(delete.map(&.id)).delete

    true
  rescue Avram::InvalidOperationError
    false
  end

  private def refresh_full_text_index
    AppDatabase.run(&.exec "REFRESH MATERIALIZED VIEW search_view")
    Lucky.logger.info("Refreshed search index")
  end
end
