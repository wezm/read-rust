class Favicon::Show < BrowserAction
  get "/favicon.ico" do
    file "public/assets/favicon.ico", disposition: "inline"
  end
end
