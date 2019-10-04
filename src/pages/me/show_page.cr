class Me::ShowPage < MainLayout
  quick_def page_title, "Your Profile"

  def content
    h1 "This is your profile"
    @current_user.try do |user|
      # FIXME: How to deal with this nicely
      h3 "Email:  #{user.email}"
    end
    helpful_tips
  end

  private def helpful_tips
    h3 "Next, you may want to:"
    ul do
      li "Modify this page: src/pages/me/show_page.cr"
      li "Change where you go after sign in: src/actions/home/index.cr"
      li "To add pages that do not require sign in, include the" +
         "Auth::AllowGuests module in your actions"
    end
  end
end
