class Search::ShowPage < MainLayout
  needs results : SearchResults

  quick_def page_title, "Search Results"
  quick_def page_description, ""

  def content
    mount Search::Form, @query

    if @results.empty?
      para "No results were found."
    else
      @results.results.each do |result|
        mount Posts::Summary, result.post, @current_user, show_categories: true, highlight: result.summary
      end

      mount Posts::Pagination, query: @query, page: @results.page, per_page: PostQuery::PER_PAGE.to_u16, total: @results.total
    end
  end
end
