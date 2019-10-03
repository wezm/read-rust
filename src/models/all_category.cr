class AllCategory
  def name
    "All"
  end

  def slug
    "all"
  end

  def recent_posts
    PostQuery.new.created_at.desc_order.limit(100)
  end
end

