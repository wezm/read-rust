class Posts::ActionBar < BaseComponent
  needs post : Post
  needs current_user : User?

  def render
    @current_user.try do
      div class: "post-action-bar" do
        link "Show", Posts::Show.with(@post.id)
        link "Edit", Posts::Edit.with(@post.id)
        twitter_url = @post.twitter_url
        mastodon_url = @post.mastodon_url
        a(href: twitter_url) { text "Tweet URL" } if twitter_url
        a(href: mastodon_url) { text "Fediverse URL" } if mastodon_url
        # link "Delete", Posts::Delete.with(@post.id), data_confirm: "Are you sure?"
      end
    end
  end
end
