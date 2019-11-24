class Me::Show < BrowserAction
  get "/me" do
    html ShowPage
  end
end
