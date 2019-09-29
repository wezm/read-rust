abstract class MainLayout
  include Lucky::HTMLPage

  # 'needs current_user : User' makes it so that the current_user
  # is always required for pages using MainLayout
  # needs current_user : User?

  abstract def content
  abstract def page_title

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(page_title: page_title, context: @context)

      body do
        mount Shared::FlashMessages.new(@context.flash)

        header do
          a href: "/" do
            text "Read "
            img alt: "", class: "logo", src: asset("images/logo.svg")
            text " Rust"
          end
          nav do
            div class: "list-inline" do
              div do
                a "Home", href: "/"
              end
              div do
                a "About", href: "/about.html"
              end
              div do
                a "Submit", href: "/submit.html"
              end
              div class: "support" do
                a "Support Rust", class: "heart", href: "/support.html"
              end
            end
          end
        end
        main class: "main" do
          h1 page_title
          content
        end
        footer do
          form action: "https://duckduckgo.com/", class: "right", id: "search", method: "get" do
            input name: "sites", type: "hidden", value: "readrust.net"
            input name: "kz", type: "hidden", value: "-1"
            input name: "kaf", type: "hidden", value: "1"
            input aria_label: "Search Read Rust", autocapitalize: "off", autocomplete: "off", id: "q", maxlength: "255", name: "q", placeholder: "Search", title: "Search Read Rust", type: "search"
            text " "
            input type: "submit", value: "Search"
          end
          text " Copyright © 2018–#{Time.utc.year} "
          a "Wesley Moore", href: "https://www.wezm.net/about/"
          text ". Read Rust is not an official Rust or Mozilla project."
          br
          text " Built with "
          a "Cobalt", href: "http://cobalt-org.github.io/"
          text ". Source on "
          a "GitHub", href: "https://github.com/wezm/read-rust"
          text ". "
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
        script do
          text " (function() { var script = document.createElement('script'); window.counter = 'https://readrust.goatcounter.com/count' script.async = 1; script.src = '//static.goatcounter.com/count.min.js'; var ins = document.getElementsByTagName('script')[0]; ins.parentNode.insertBefore(script, ins) })(); "
        end
      end
    end


  end

  private def render_signed_in_user(user)
    text user.email
    text " - "
    link "Sign out", to: SignIns::Delete, flow_id: "sign-out-button"
  end
end
