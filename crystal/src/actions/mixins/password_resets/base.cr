module Auth::PasswordResets::Base
  macro included
    include Auth::RedirectSignedInUsers
    include Auth::PasswordResets::FindUser
    include Auth::PasswordResets::RequireToken
  end
end
