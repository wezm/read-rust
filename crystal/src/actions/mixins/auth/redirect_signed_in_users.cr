module Auth::RedirectSignedInUsers
  macro included
    include Auth::AllowGuests
    before redirect_signed_in_users
  end

  private def redirect_signed_in_users
    if current_user?
      flash.success = "You are already signed in"
      redirect to: Home::Index
    else
      continue
    end
  end

  # current_user returns nil because signed in users are redirected.
  def current_user
  end
end
