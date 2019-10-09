class Posts::New < BrowserAction
  get "/posts/new" do
    html NewPage, form: SavePost.new, categories: CategoryQuery.new
  end
end
