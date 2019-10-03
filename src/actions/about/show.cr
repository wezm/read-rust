class About::Show < BrowserAction
  include Auth::AllowGuests

  get "/about" do
    render ShowPage, categories: CategoryQuery.new
  end
end
