class Api::Me::Show < ApiAction
  get "/api/me" do
    json UserSerializer.new(current_user)
  end
end
