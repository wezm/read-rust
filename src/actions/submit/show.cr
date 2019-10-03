class Submit::Show < BrowserAction
  include Auth::AllowGuests

  get "/submit" do
    render ShowPage
  end
end
