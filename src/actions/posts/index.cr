class Posts::Index < BrowserAction
  include Auth::AllowGuests

  get "/all" do
    render Posts::IndexPage, posts: PostQuery.new
  end
end
