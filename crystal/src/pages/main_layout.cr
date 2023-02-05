abstract class MainLayout
  include Lucky::HTMLPage

  # 'needs current_user : User' makes it so that the current_user
  # is always required for pages using MainLayout
  needs current_user : User?
  needs query : String = ""

  abstract def content
  abstract def page_title
  abstract def page_description

  def app_js? : Bool
    false
  end

  def admin? : Bool
    !@current_user.nil?
  end

  def extra_css : String?
    nil
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead, page_title: page_title, page_description: page_description, context: @context, categories: CategoryQuery.new, app_js: app_js?, admin: admin?, extra_css: extra_css

      body do
        mount Shared::Header, @current_user, @query
        mount Shared::FlashMessages, @context.flash
        main class: "main" do
          h1 page_title
          content
        end
        footer do
          text " Copyright © 2018–#{Time.utc.year} "
          a "Wesley Moore", href: "https://www.wezm.net/v2/about/"
          text ". Read Rust is not an official Rust or Mozilla project."
          br
          text "Revision "
          a href: "https://github.com/wezm/read-rust/commit/#{ReadRust::Config.revision}" do
            code ReadRust::Config.revision
          end
          text ". Source on "
          a "GitHub", href: "https://github.com/wezm/read-rust"
          text "."
          div class: "socials" do
            a href: "/all/feed.rss" do
              img alt: "Read Rust RSS feed", src: asset("images/rss.svg")
            end
            a href: "https://twitter.com/read_rust" do
              img alt: "Read Rust on Twitter", src: asset("images/twitter.svg")
            end
            a href: "https://botsin.space/@readrust", rel: "me" do
              img alt: "Read Rust on Mastodon", src: asset("images/mastodon.svg")
            end
            a href: "https://www.facebook.com/readrust/" do
              img alt: "Read Rust on Facebook", src: asset("images/facebook.svg")
            end
            a href: "https://github.com/wezm/read-rust" do
              img alt: "Read Rust on GitHub", src: asset("images/github.svg")
            end
          end
        end
        if Lucky::Env.production?
          script src: "//gc.zgo.at/count.js", attrs: [:async], data_goatcounter: "https://readrust.goatcounter.com/count"
        end
      end
    end
  end
end
