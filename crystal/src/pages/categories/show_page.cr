class Categories::ShowPage < MainLayout
  needs category : Category
  needs posts : PostQuery
  quick_def page_title, @category.name
  quick_def page_description, "This page lists posts in the #{@category.name} category."

  def content
    text @category.description

    h2 do
      text " Posts "
      link class: "feedicon", to: RssFeed::Show.with(@category.slug), title: "#{@category.name} RSS Feed" do
        img src: asset("images/rss.svg")
      end
      link class: "feedicon", to: JsonFeed::Show.with(@category.slug), title: "#{@category.name} JSON Feed" do
        img src: asset("images/jsonfeed.png")
      end
    end

    maybe_include_post_count(@category.year, @posts)

    @posts.each do |post|
      mount Posts::Summary, post, @current_user, show_categories: false
    end
  end

  private def maybe_include_post_count(year : UInt16?, posts : PostQuery)
    if year
      post_count = posts.clone.select_count
      if year < Time.utc.year + 1
        para "#{pluralize(post_count, "post")} were made by the Rust commmunity:"
      else
        para "#{pluralize(post_count, "post")} have been made by the Rust commmunity:"
      end
    end
  end
end
