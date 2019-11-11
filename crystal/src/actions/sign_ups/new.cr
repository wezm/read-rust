class SignUps::New < BrowserAction
  include Auth::RedirectSignedInUsers

  get "/sign_up" do
    if ReadRust::Config.allow_sign_up?
      html NewPage, operation: SignUpUser.new
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
