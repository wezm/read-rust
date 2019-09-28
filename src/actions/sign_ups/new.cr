class SignUps::New < BrowserAction
  include Auth::RedirectSignedInUsers

  get "/sign_up" do
    render NewPage, operation: SignUpUser.new
  end
end
