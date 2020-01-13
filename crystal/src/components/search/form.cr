class Search::Form < BaseComponent
  needs query : String = ""

  def render
    form action: "/search", class: "search-form", method: "get" do
      input aria_label: "Search Read Rust", autocapitalize: "off", autocomplete: "off", id: "q", maxlength: "255", name: "q", placeholder: "Search", title: "Search Read Rust", type: "search", value: @query
      text " "
      input type: "submit", value: "Search"
    end
  end
end
