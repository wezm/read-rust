class Creators::IndexPage < MainLayout
  quick_def page_title, "Support Rust"
  quick_def page_description, "This page used to list people and projects contributing to the Rust ecosystem that are accepting financial contributions."

  def app_js?
    true
  end

  def content
    para do
      text "This page used to list people and projects in the Rust ecosystem that were accepting financial contributions."
      text " It became stale so has been removed. To support folks consider using "
      a "cargo fund", href: "https://github.com/acfoltzer/cargo-fund"
      text " on your projects."
    end
  end
end
