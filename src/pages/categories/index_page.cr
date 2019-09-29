class Categories::IndexPage < MainLayout
  needs categories : CategoryQuery
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
      text " or any of the wonderful people building and writing in Rust."
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
      a class: "feedicon", href: "/all/feed.rss", title: "Read Rust RSS Feed" do
        img src: asset("images/rss.svg")
      end
      a class: "feedicon", href: "/all/feed.json", title: "Read Rust JSON Feed" do
        img src: asset("images/jsonfeed.png")
      end
    end
    ul do
      li do
        a "Improvement to the compile time of a crate", href: "http://antoyo.ml/compilation-time-dependencies"
        text " by Antoni Boucher in "
        a "Performance", href: "/performance/"
      end
      li do
        a "Async Stack Traces in Rust", href: "http://fitzgeraldnick.com/2019/08/27/async-stacks-in-rust.html"
        text " by Nick Fitzgerald in "
        a "Language", href: "/language/"
      end
      li do
        a "Writing Linux Kernel Module in Rust", href: "https://github.com/lizhuohua/linux-kernel-module-rust"
        text " by Li Zhuohua in "
        a "Operating Systems", href: "/operating-systems/"
      end
      li do
        a "Linux.Fe2O3: a Rust virus", href: "https://www.guitmz.com/linux-fe2o3-rust-virus/"
        text " by Guilherme Thomazi in "
        a "Security", href: "/security/"
      end
      li do
        a "Diagnostics with Tracing", href: "https://tokio.rs/blog/2019-08-tracing/"
        text " by Eliza Weisman in "
        a "Crates", href: "/crates/"
      end
      li do
        a "How Rust optimizes async/await II: Program analysis", href: "https://tmandry.gitlab.io/blog/posts/optimizing-await-2/"
        text " by Tyler Mandry in "
        a "Performance", href: "/performance/"
        text ", "
        a "Language", href: "/language/"
      end
      li do
        a "We want smaller, faster, more secure native apps", href: "https://medium.com/tauri-apps/we-want-smaller-faster-more-secure-native-apps-77222f590c64"
        text " by nothingismagick in "
        a "Crates", href: "/crates/"
      end
      li do
        a "Rustacean Terminal Chat App in Rust", href: "https://www.pubnub.com/blog/build-realtime-rust-chat-app-cursive-tui/"
        text " by Samba Diallo in "
        a "Web and Network Services", href: "/web-and-network-services/"
        text ", "
        a "Getting Started", href: "/getting-started/"
      end
      li do
        a "Wrapping Unsafe C Libraries in Rust", href: "https://medium.com/dwelo-r-d/wrapping-unsafe-c-libraries-in-rust-d75aeb283c65"
        text " by Jeff Hiner in "
        a "Language", href: "/language/"
      end
      li do
        a "Understanding Futures in Rust -- Part 2", href: "https://www.viget.com/articles/understanding-futures-is-rust-part-2/"
        text " by Joe Jackson in "
        a "Language", href: "/language/"
      end
    end
    para do
      a "View all posts", href: "/all/"
    end
  end
end
