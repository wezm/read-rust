module Auth::AllowGuests
  macro included
    skip require_sign_in
  end

  # Since sign in is not required, current_user might be nil
  def current_user : User?
    current_user?
  end
end
