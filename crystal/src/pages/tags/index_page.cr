class Tags::IndexPage < MainLayout
  needs tags : Array(String)
  quick_def page_title, "Tags"
  quick_def page_description, "This page lists all the tags that posts are categorised by."

  def content
    @tags.each do |tag|
      text " "
      link tag, to: Tags::Show.with(tag), class: "tag"
    end
  end
end
