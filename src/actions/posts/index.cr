class Posts::Index < BrowserAction
  include Auth::AllowGuests

  get "/all" do
    html Posts::IndexPage, posts: PostQuery.new
  end
end
