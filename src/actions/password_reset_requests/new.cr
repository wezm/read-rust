class PasswordResetRequests::New < BrowserAction
  include Auth::RedirectSignedInUsers

  route do
    html NewPage, operation: RequestPasswordReset.new
  end
end
