class Tags::ShowPage < MainLayout
  needs tag : Tag
  needs posts : PostQuery
  quick_def page_title, "Tag: #{@tag.name}"

  def content
    h2 do
      text "Posts "
      link class: "feedicon", to: Tags::Show.with(@tag.name + ".rss"), title: "#{@tag.name} RSS Feed" do
        img src: asset("images/rss.svg")
      end
      link class: "feedicon", to: Tags::Show.with(@tag.name + ".json"), title: "#{@tag.name} JSON Feed" do
        img src: asset("images/jsonfeed.png")
      end
    end

    @posts.each do |post|
      mount Posts::Summary.new(post, @current_user, show_categories: true)
    end

    para do
      link "View all tags", Tags::Index
    end
  end
end
