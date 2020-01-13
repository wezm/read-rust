class Posts::Summary < BaseComponent
  needs post : Post
  needs current_user : User?
  needs show_categories : Bool = false
  needs highlight : String? = nil

  private SUBSTITUTIONS = {
    '\u0012' => "<mark>",
    '\u0014' => "</mark>",
  }

  def render
    article do
      a @post.title, href: @post.url
      text " by #{@post.author}"
      if @show_categories
        text " in "
        @post.post_categories.each_with_index do |cat, index|
          text ", " if index != 0
          link cat.name, to: Categories::Show.with(cat.slug)
        end
      end
      tag "blockquote" do
        simple_format(safe_summary)
      end

      @post.tags.each do |tag|
        text " "
        link tag.name, to: Tags::Show.with(tag.name), class: "tag"
      end
      mount Posts::ActionBar.new(@post, @current_user)
    end
  end

  def safe_summary : String
    summary = @highlight || @post.summary
    HTML.escape(summary).gsub(SUBSTITUTIONS)
  end
end
