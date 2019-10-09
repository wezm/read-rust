class Creators::Index < BrowserAction
  include Auth::AllowGuests

  get "/support" do
    html IndexPage, creators: CreatorQuery.new.preload_tags, tags: TagQuery.new
  end
end
