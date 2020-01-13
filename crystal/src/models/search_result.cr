class SearchResult
  getter post
  getter summary

  def initialize(@post : Post, @summary : String)
  end
end
