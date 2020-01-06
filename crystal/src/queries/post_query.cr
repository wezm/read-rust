class PostQuery < Post::BaseQuery
  PER_PAGE = 20

  def recent_in_category(category)
    if category.all?
      created_at.desc_order
    else
      where_post_categories(PostCategoryQuery.new.category_id(category.id)).created_at.desc_order
    end
  end

  def last_modified_in_category(category)
    recent_in_category(category).updated_at.select_max
  end

  def self.search(query)
    sql = <<-SQL
      SELECT id from search_view
      WHERE vector @@ websearch_to_tsquery('english', $1) limit #{PER_PAGE}
    SQL

    ids = AppDatabase.run do |db|
      db.query_all sql, query, &.read(Int64)
    end

    PostQuery.new.id.in(ids)
  end
end
