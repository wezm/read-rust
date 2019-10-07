class Categories::IndexPage < MainLayout
  needs categories : CategoryQuery
  needs recent_posts : PostQuery
  quick_def page_title, "Home"

  def content
    para do
      text "Read Rust collects interesting posts related to the "
      a href: "https://www.rust-lang.org/" do
        text "Rust programming language"
      end
      text "."
    end
    para do
      a "Subscribe to a feed", href: "/about.html#feeds"
      text ", or follow Read Rust on "
      a "Twitter", href: "https://twitter.com/read_rust"
      text ", "
      a "Mastodon", href: "https://botsin.space/@readrust"
      text " or "
      a "Facebook", href: "https://www.facebook.com/readrust/"
      text " to receive new posts as they're added."
    end
    para do
      text "Read Rust is run by "
      a "Wesley Moore", href: "http://www.wezm.net/about/"
      text ". If you enjoy it, consider "
      a href: "https://patreon.com/wezm" do
        text "supporting me"
      end
      text " or any of the "
      link "wonderful people building and writing in Rust", to: Creators::Index
      text "."
    end
    h2 "Sections"
    para "New posts are added to one or more of the following sections:"

    ul do
      li do
        a "All Posts", href: "/all/"
      end
      @categories.each do |category|
        li do
          link category.name, to: Categories::Show.with(category.slug)
          text " — #{category.description}."
        end
      end
    end

    h2 do
      text " Recent Posts "
      link class: "feedicon", to: RssFeed::Show.with("all"), title: "Read Rust RSS Feed" do
        img src: asset("images/rss.svg")
      end
      link class: "feedicon", to: JsonFeed::Show.with("all"), title: "Read Rust JSON Feed" do
        img src: asset("images/jsonfeed.png")
      end
    end
    ul do
      @recent_posts.each do |post|
        li do
          a post.title, href: post.url
          text " by #{post.author} in "
          post.categories.each_with_index do |category, index|
            text ", " unless index == 0
            link category.name, to: Categories::Show.with(category.slug)
          end
        end
      end
    end

    link "View all posts", to: Categories::Show.with("all")
  end
end
