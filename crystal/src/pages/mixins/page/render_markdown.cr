module Page::RenderMarkdown
  def render_markdown(source)
    options = Markd::Options.new(smart: true)
    Markd.to_html(source, options)
  end
end
