class Posts::IndexPage < MainLayout
  needs posts : PostQuery
  quick_def page_title, "All Posts"

  def content
    text "All #{@posts.size} posts. "
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
      @posts.each do |post|
        li do
          a post.title, href: post.url
          text " by #{post.author}"
        end
      end
    end
  end
end
