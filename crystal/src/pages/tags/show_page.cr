class Tags::ShowPage < MainLayout
  needs tag : Tag
  needs posts : PostQuery
  quick_def page_title, "Posts tagged: #{@tag.name}"

  def content
    @posts.each do |post|
      mount Posts::Summary.new(post, @current_user, show_categories: true)
    end

    para do
      link "View all tags", Tags::Index
    end
  end
end
