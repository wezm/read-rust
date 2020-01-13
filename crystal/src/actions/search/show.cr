class Search::Show < BrowserAction
  include Auth::AllowGuests

  param q : String = ""

  get "/search" do
    if q.blank?
      flash.failure = "You need to specify what to search for"
      html Search::ShowPage, query: q, results: [] of SearchResult
    else
      html Search::ShowPage, query: q, results: PostQuery.search(q)
    end
  end
end
