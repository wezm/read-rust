class SignIns::New < BrowserAction
  include Auth::RedirectSignedInUsers

  get "/sign_in" do
    render NewPage, operation: SignInUser.new
  end
end
