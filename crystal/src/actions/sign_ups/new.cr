class SignUps::New < BrowserAction
  include Auth::RedirectSignedInUsers

  get "/sign_up" do
    html NewPage, operation: SignUpUser.new
  end
end
