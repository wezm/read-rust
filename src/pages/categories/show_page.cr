class Categories::ShowPage < MainLayout
  needs category : Category
  needs posts : PostQuery
  quick_def page_title, @category.name

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

    ul do
      @posts.each do |post|
        article do
          a post.title, href: post.url
          text " by #{post.author}"
          tag "blockquote" do
            simple_format(post.summary)
          end
        end
      end
    end
  end
end
