class Categories::ShowPage < MainLayout
  needs category : Category
  quick_def page_title, @category.name

  def content
    text @category.description

    h2 do
      text " Posts "
      a class: "feedicon", href: "/all/feed.rss", title: "All Posts RSS Feed" do
        img src: asset("images/rss.svg")
      end
      a class: "feedicon", href: "/all/feed.json", title: "All Posts JSON Feed" do
        img src: asset("images/jsonfeed.png")
      end
    end

    ul do
      @category.posts.each do |post|
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
