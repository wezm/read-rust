class Posts::New < BrowserAction
  get "/posts/new" do
    render NewPage, form: SavePost.new, categories: CategoryQuery.new
  end
end
