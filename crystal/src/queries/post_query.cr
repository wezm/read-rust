class PostQuery < Post::BaseQuery
  PER_PAGE = 10_u16
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

  def self.search(query : String, page : Page) : SearchResults
    results = execute_search(query, page)
    total = execute_search_total(query)

    ids = results.map { |result| result[:id] }
    id_to_post = {} of Int64 => Post
    PostQuery.new.id.in(ids).preload_post_categories.preload_tags.each do |post|
      id_to_post[post.id] = post
    end

    post_results = results.map do |result|
      post = id_to_post[result[:id]]
      next if post.nil?
      SearchResult.new(post, result[:summary])
    end.compact
    SearchResults.new(post_results, page, total.to_u32)
  end

  private def self.execute_search(query : String, page : Page) : Array({id: Int64, summary: String})
    sql = <<-SQL
      SELECT
        id,
        ts_headline('english', summary, websearch_to_tsquery('english', $1), 'HighlightAll = true, StartSel = "#{DC2}", StopSel = "#{DC4}"')
      FROM search_view
      WHERE vector @@ websearch_to_tsquery('english', $1)
      OFFSET #{(page.to_i - 1) * PER_PAGE}
      LIMIT #{PER_PAGE}
    SQL

    AppDatabase.run do |db|
      db.query_all sql, query, as: {id: Int64, summary: String}
    end
  end

  private def self.execute_search_total(query : String) : Int64
    sql = <<-SQL
      SELECT count(id)
      FROM search_view
      WHERE vector @@ websearch_to_tsquery('english', $1)
    SQL

    AppDatabase.run do |db|
      db.query_one sql, query, as: Int64
    end
  end
end
