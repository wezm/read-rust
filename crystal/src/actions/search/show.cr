class Search::Show < BrowserAction
  include Auth::AllowGuests

  param q : String = ""

  get "/search" do
    if q.blank?
      flash.failure = "You need to specify what to search for"
      html Search::ShowPage, query: q, posts: PostQuery.new.none
    else
      html Search::ShowPage, query: q, posts: PostQuery.search(q).preload_post_categories.preload_tags
    end
  end
end
