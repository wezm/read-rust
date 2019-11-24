class Posts::New < BrowserAction
  get "/posts/new" do
    html NewPage, form: SavePost.new
  end
end
