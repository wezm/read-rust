class Posts::IndexPage < MainLayout
  needs posts : PostQuery
  quick_def page_title, "All Posts"
  quick_def page_description, "This page lists all posts that have been pulished on Read Rust."

  def content
    text "All #{@posts.size} posts. "
    h2 do
      text " Posts "
      link class: "feedicon", to: RssFeed::Show.with("all"), title: "All Posts RSS Feed" do
        img src: asset("images/rss.svg")
      end
      link class: "feedicon", to: JsonFeed::Show.with("all"), title: "All Posts JSON Feed" do
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
