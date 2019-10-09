class SignIns::Create < BrowserAction
  include Auth::RedirectSignedInUsers

  route do
    SignInUser.new(params).submit do |operation, authenticated_user|
      if authenticated_user
        sign_in(authenticated_user)
        flash.success = "You're now signed in"
        Authentic.redirect_to_originally_requested_path(self, fallback: Home::Index)
      else
        flash.failure = "Sign in failed"
        html NewPage, operation: operation
      end
    end
  end
end
