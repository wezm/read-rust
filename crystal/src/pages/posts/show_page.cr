class Posts::ShowPage < MainLayout
  needs post : Post
  quick_def page_title, @post.title

  def content
    mount Posts::Summary.new(@post, @current_user, show_categories: true)
  end
end
