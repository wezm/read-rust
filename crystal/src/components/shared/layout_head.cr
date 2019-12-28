class Shared::LayoutHead < BaseComponent
  needs page_title : String
  needs page_description : String
  needs app_js : Bool
  needs admin : Bool
  needs extra_css : String?
  # This is used by the 'csrf_meta_tags' method
  needs context : HTTP::Server::Context
  needs categories : CategoryQuery

  def render
    head do
      utf8_charset
      title "#{@page_title} – Read Rust"
      css_link asset("css/app.css"), data_turbolinks_track: "reload"
      js_link asset("js/app.js"), defer: "true", data_turbolinks_track: "reload" if @app_js

      if @admin
        css_link asset("css/admin.css"), data_turbolinks_track: "reload"
        js_link asset("js/admin.js"), defer: "true", data_turbolinks_track: "reload"
      end
      meta name: "turbolinks-cache-control", content: "no-cache"
      csrf_meta_tags
      responsive_meta_tag

      @categories.each do |category|
        tag "link", href: RssFeed::Show.with(category.slug).url, rel: "alternate", title: "Read Rust - #{category.name}", type: "application/rss+xml"
      end

      meta content: "Read Rust collects and categorises interesting posts related to the Rust programming language. #{@page_description}", name: "description"
      css_link dynamic_asset(@extra_css), data_turbolinks_track: "reload" if @extra_css
    end
  end
end
