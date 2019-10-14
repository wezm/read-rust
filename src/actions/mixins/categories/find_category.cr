module Categories::FindCategory
  private def category
    if category = CategoryQuery.new.slug(slug).first?
      category
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
