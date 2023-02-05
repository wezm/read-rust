class SignUps::Create < BrowserAction
  include Auth::RedirectSignedInUsers

  post "/sign_ups" do
    if ReadRust::Config.allow_sign_up?
      SignUpUser.create(params) do |operation, user|
        if user
          flash.info = "Thanks for signing up"
          cache_friendly_sign_in(user)
          redirect to: Home::Index
        else
          flash.info = "Couldn't sign you up"
          html NewPage, operation: operation
        end
      end
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
