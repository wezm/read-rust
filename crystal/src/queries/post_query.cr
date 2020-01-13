class PostQuery < Post::BaseQuery
  PER_PAGE = 20
  DC2 = '\u0012'
  DC4 = '\u0014'

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

  def self.search(query) : Array(SearchResult)
    results = execute_search(query)
    ids = results.map { |result| result[:id] }
    id_to_post = {} of Int64 => Post
    PostQuery.new.id.in(ids).preload_post_categories.preload_tags.each do |post|
      id_to_post[post.id] = post
    end

    results.map do |result|
      post = id_to_post[result[:id]]
      next if post.nil?
      SearchResult.new(post, result[:summary])
    end.compact
  end

  private def self.execute_search(query) : Array({id: Int64, summary: String})
    sql = <<-SQL
      SELECT
        id,
        ts_headline('english', summary, websearch_to_tsquery('english', $1), 'HighlightAll = true, StartSel = "#{DC2}", StopSel = "#{DC4}"')
      FROM search_view
      WHERE vector @@ websearch_to_tsquery('english', $1) limit #{PER_PAGE}
    SQL

    AppDatabase.run do |db|
      db.query_all sql, query, as: {id: Int64, summary: String}
    end
  end
end
