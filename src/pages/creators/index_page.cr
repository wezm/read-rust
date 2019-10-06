class Creators::IndexPage < MainLayout
  needs creators : CreatorQuery
  needs tags : TagQuery
  quick_def page_title, "Support Rust"

  def app_js?
    true
  end

  def extra_css
    "css/balloon.css"
  end

  def content
    para do
      text " If you or your company benefits from Rust and its ecosystem consider supporting it. There are many ways to support Rust: "
    end
    ul do
      li "Contribute code."
      li "Write documentation."
      li "Publish blog posts, videos, or podcasts."
      li do
        text " Answer questions on "
        a "the forum", href: "https://users.rust-lang.org/"
        text ", "
        a "Stack Overflow", href: "https://stackoverflow.com/unanswered/tagged/rust"
        text ", "
        a "Reddit", href: "https://www.reddit.com/r/rust"
        text ", "
        a "Matrix", href: "https://matrix.to/#/#rust:matrix.org"
        text ", or "
        a "Discord", href: "https://discord.gg/rust-lang"
        text ". "
      end
      li "Financial contribution."
    end
    para do
      text " Open source has a bit of a problem with sustainability and burning people out. Paying people is one way that we can help compensate them for their time and make open source more sustainable. "
    end
    para do
      text " Below are people and projects contributing to the Rust ecosystem that are accepting financial contributions. If you or your company is able, consider supporting one or more of these fine folks in their work making Rust better. See also "
      a "Aaron Turon's list", href: "http://aturon.github.io/sponsor"
      text ". "
    end
    para do
      text " To add to, or update this list "
      a "please raise an issue", href: "https://github.com/wezm/read-rust/issues/new?labels=support-rust&template=support_rust.md"
      text ". "
    end
    section id: "featured"
    section do
      h2 "Rust Creators", id: "rust-creators"
      div class: "filter" do
        strong "Filter:", class: "visually-hidden"
        tag_link("all")
        @tags.each do |tag|
          text " "
          tag_link(tag.name)
        end
      end
      ul aria_label: "Rust creators", class: "creators", id: "creators" do
        @creators.each do |creator|
          li class: "card", data_tags: data_tags(creator), id: creator.code_link_name do
            div class: "content" do
              img alt: "", src: dynamic_asset(creator.avatar_thumbnail), width: "50"
              h3 do
                text creator.name
              end
              div class: "meta" do
                a creator.code_link_name, href: creator.code_link_url
              end
              div class: "description" do
                raw creator.description
              end
            end
            div class: "card-extra" do
              a creator.support_link_name, class: "button", href: creator.support_link_url
            end
          end
        end
      end
    end
  end

  private def tag_link(tag_name)
    a tag_name, class: "tag", href: "##{tag_name}"
  end

  private def data_tags(creator)
    creator.tags.map(&.name).join(",")
  end
end
