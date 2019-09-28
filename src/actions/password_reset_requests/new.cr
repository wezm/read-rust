class PasswordResetRequests::New < BrowserAction
  include Auth::RedirectSignedInUsers

  route do
    render NewPage, operation: RequestPasswordReset.new
  end
end
