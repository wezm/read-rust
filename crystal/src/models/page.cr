# A type representing a page number
#
# Will always be in the range 1..=UInt16::MAX
struct Page
  delegate to_i, to_u16, to_u32, to_s, succ, pred, to: @page

  def initialize(page)
    if page < 1 || page > UInt16::MAX
      @page = 1_u16
    else
      @page = page.to_u16
    end
  end

  def first?
    @page == 1_u16
  end
end
