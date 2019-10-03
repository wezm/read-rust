class PostQuery < Post::BaseQuery
  def recent_in_category(category)
    if category.slug == "all"
      created_at.desc_order
    else
      where_categories(CategoryQuery.new.slug(category.slug)).created_at.desc_order
    end
  end
end
