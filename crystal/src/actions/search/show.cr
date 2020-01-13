class Search::Show < BrowserAction
  include Auth::AllowGuests

  param q : String = ""
  param page : Int32 = 1 # Trying to make this UInt16 or UInt32 gives Error: undefined constant UInt32::Lucky

  get "/search" do
    if q.blank?
      flash.failure = "You need to specify what to search for"
      html Search::ShowPage, query: q, results: SearchResults.none
    else
      html Search::ShowPage, query: q, results: PostQuery.search(q, Page.new(page))
    end
  end
end
