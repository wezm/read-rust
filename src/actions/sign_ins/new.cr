class SignIns::New < BrowserAction
  include Auth::RedirectSignedInUsers

  get "/sign_in" do
    html NewPage, operation: SignInUser.new
  end
end
