class Posts::Index < BrowserAction
  include Auth::AllowGuests

  get "/all" do
    html Posts::IndexPage, posts: PostQuery.new.created_at.desc_order
  end
end
