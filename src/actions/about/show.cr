class About::Show < BrowserAction
  get "/about" do
    plain_text "Render something in About::Show"
  end
end
