class About::Show < BrowserAction
  include Auth::AllowGuests

  get "/about" do
    plain_text "Render something in About::Show"
  end
end
