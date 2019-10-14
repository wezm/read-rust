class PostQuery < Post::BaseQuery
  def recent_in_category(category)
    if category.all?
      created_at.desc_order
    else
      where_post_categories(PostCategoryQuery.new.category_id(category.id)).created_at.desc_order
    end
  end
end
