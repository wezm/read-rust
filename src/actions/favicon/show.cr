class Favicon::Show < BrowserAction
  include Auth::AllowGuests

  get "/favicon.ico" do
    file "public/assets/favicon.ico", disposition: "inline"
  end
end
