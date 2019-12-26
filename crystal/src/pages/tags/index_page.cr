class Tags::IndexPage < MainLayout
  needs tags : Array(String)
  quick_def page_title, "Tags"

  def content
    @tags.each do |tag|
      text " "
      link tag, to: Tags::Show.with(tag), class: "tag"
    end
  end
end
