class Creators::Index < BrowserAction
  include Auth::AllowGuests

  get "/support" do
    plain_text "Render something in Creators::Index"
  end
end
