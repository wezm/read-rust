class Posts::Index < BrowserAction
  get "/all" do
    render Posts::IndexPage, posts: PostQuery.new
  end
end
