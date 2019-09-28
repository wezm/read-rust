class Home::Index < BrowserAction
  include Auth::AllowGuests

  get "/" do
    render Categories::IndexPage, categories: CategoryQuery.new
  end
end
