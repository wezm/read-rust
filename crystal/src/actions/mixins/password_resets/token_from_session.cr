module Auth::PasswordResets::TokenFromSession
  private def token : String
    session.get?(:password_reset_token) || raise "Password reset token not found in session"
  end
end
