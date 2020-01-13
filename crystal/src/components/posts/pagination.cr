class Posts::Pagination < BaseComponent
  needs query : String
  needs page : Page
  needs total : UInt32
  needs per_page : UInt16

  @total_pages : UInt16?

  def render
    div class: "pagination" do
      first_page
      prev_page
      span class: "pagination-link" do
        raw "Page #{@page}&nbsp;of&nbsp;#{total_pages}"
      end
      next_page
      last_page
    end
  end

  private def prev_page
    if @page.first?
      span "← Previous", class: "pagination-link"
    else
      page_link "← Previous", @page.pred
    end
  end

  private def next_page
    if @page.to_u32 >= total_pages
      span "Next →", class: "pagination-link"
    else
      page_link "Next →", @page.succ
    end
  end

  private def first_page
    if @page.first?
      span "⇤ First", class: "pagination-link pagination-link-bounds"
    else
      page_link "⇤ First", 1, "pagination-link-bounds"
    end
  end

  private def last_page
    if @page.to_u32 == total_pages
      span "Last ⇥", class: "pagination-link pagination-link-bounds"
    else
      page_link "Last ⇥", total_pages, "pagination-link-bounds"
    end
  end

  private def page_link(text, page : UInt16, klass : String = "")
    # FIXME: Don't hardcode the route helper
    link text, to: Search::Show.with(q: @query, page: page.to_i), class: "pagination-link #{klass}"
  end

  private def total_pages : UInt16
    @total_pages ||= (@total.to_f / @per_page.to_f).ceil.to_u16
  end
end
