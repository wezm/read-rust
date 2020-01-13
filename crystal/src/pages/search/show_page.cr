class Search::ShowPage < MainLayout
  needs query : String
  needs results : Array(SearchResult)

  quick_def page_title, "Search Results"
  quick_def page_description, ""

  def content
    mount Search::Form.new(@query)

    if @results.empty?
      para "No results were found."
    else
      @results.each do |result|
        mount Posts::Summary.new(result.post, @current_user, show_categories: true, highlight: result.summary)
      end
    end
  end
end
