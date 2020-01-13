abstract class MainLayout
  include Lucky::HTMLPage

  # 'needs current_user : User' makes it so that the current_user
  # is always required for pages using MainLayout
  needs current_user : User?
  # FIXME: Enable when there's a Lucky release with this fix in it
  # https://github.com/luckyframework/lucky/pull/993
  # needs query : String = ""

  @query : String = ""

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
      mount Shared::LayoutHead.new(page_title: page_title, page_description: page_description, context: @context, categories: CategoryQuery.new, app_js: app_js?, admin: admin?, extra_css: extra_css)

      body do
        mount Shared::Header.new(@current_user, @query)
        mount Shared::FlashMessages.new(@context.flash)
        main class: "main" do
          h1 page_title
          content
        end
        footer do
          text " Copyright © 2018–#{Time.utc.year} "
          a "Wesley Moore", href: "https://www.wezm.net/about/"
          text ". Read Rust is not an official Rust or Mozilla project."
          br
          text "Revision "
          link "https://github.com/wezm/read-rust/commit/#{ReadRust::Config.revision}" do
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
            a href: "https://botsin.space/@readrust" do
              img alt: "Read Rust on Mastodon", src: asset("images/mastodon.svg")
            end
            a href: "https://www.facebook.com/readrust/" do
              img alt: "Read Rust on Facebook", src: asset("images/facebook.svg")
            end
            a href: "https://github.com/wezm/read-rust" do
              img alt: "Read Rust on GitHub", src: asset("images/github.svg")
            end
            a href: "https://patreon.com/wezm" do
              img alt: "Support me on Patreon", src: asset("images/patreon.svg")
            end
          end
        end
        if Lucky::Env.production?
          script do
            raw <<-JS
            (function() {
              var script = document.createElement('script');
              window.counter = 'https://readrust.goatcounter.com/count'
              script.async = 1;
              script.src = '//static.goatcounter.com/count.min.js';

              var ins = document.getElementsByTagName('script')[0];
              ins.parentNode.insertBefore(script, ins)
            })();
            JS
          end
        end
      end
    end
  end
end
