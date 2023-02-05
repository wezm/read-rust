class Posts::ShowPage < MainLayout
  needs post : Post
  quick_def page_title, @post.title
  quick_def page_description, @post.summary

  def content
    mount Posts::Summary, @post, @current_user, show_categories: true
  end
end
