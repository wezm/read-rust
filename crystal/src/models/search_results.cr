class SearchResults
  getter results
  getter total
  getter page

  def self.none
    new([] of SearchResult, Page.new(1), 0)
  end

  def initialize(@results : Array(SearchResult), @page : Page, @total : UInt32)
  end

  def empty?
    @total == 0
  end
end
