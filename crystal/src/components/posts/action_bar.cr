class Posts::ActionBar < BaseComponent
  needs post : Post
  needs current_user : User?

  def render
    @current_user.try do
      div class: "post-action-bar" do
        link "Show", Posts::Show.with(@post.id)
        link "Edit", Posts::Edit.with(@post.id)
        # link "Delete", Posts::Delete.with(@post.id), data_confirm: "Are you sure?"
      end
    end
  end
end
