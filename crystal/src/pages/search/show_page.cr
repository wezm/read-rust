class Search::ShowPage < MainLayout
  needs query : String
  needs posts : PostQuery

  quick_def page_title, "Search Results"
  quick_def page_description, ""

  def content
    mount Search::Form.new(@query)

    count = 0
    @posts.each do |post|
      count += 1
      mount Posts::Summary.new(post, @current_user, show_categories: true)
    end

    if count.zero?
      para "No results were found."
    end
  end
end
