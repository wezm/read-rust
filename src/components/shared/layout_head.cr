class Shared::LayoutHead < BaseComponent
  needs page_title : String
  needs app_js : Bool
  needs extra_css : String?
  # This is used by the 'csrf_meta_tags' method
  # needs context : HTTP::Server::Context

  def render
    head do
      utf8_charset
      title "#{@page_title} – Read Rust"
      css_link asset("css/app.css"), data_turbolinks_track: "reload"
      js_link asset("js/app.js"), defer: "true", data_turbolinks_track: "reload" if @app_js
      meta name: "turbolinks-cache-control", content: "no-cache"
      # csrf_meta_tags
      responsive_meta_tag

      # text "{% for category in site.data.categories %} "
      tag "link", href: "{{ category.path }}feed.rss", rel: "alternate", title: "Read Rust - {{ category.name | escape }}", type: "application/rss+xml"
      # text " {% endfor %} "
      meta content: "Read Rust collects interesting posts related to the Rust programming language.", name: "description"
      css_link dynamic_asset(@extra_css), data_turbolinks_track: "reload" if @extra_css
    end
  end
end
