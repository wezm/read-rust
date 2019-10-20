class Posts::ShowPage < MainLayout
  needs post : Post
  quick_def page_title, @post.title

  def content
    article do
      a @post.title, href: @post.url
      text " by #{@post.author}"
      tag "blockquote" do
        simple_format(@post.summary)
      end

      ul do
        @post.post_categories.each do |cat|
          li do
            text cat.name
          end
        end
      end

      link "Edit", to: Posts::Edit.with(@post)
    end
  end
end
