class Submit::Show < BrowserAction
  include Auth::AllowGuests

  get "/submit" do
    html ShowPage
  end
end
