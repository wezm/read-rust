module Categories::FindCategory
  private def category
    if slug == "all"
      AllCategory.new
    elsif category = CategoryQuery.new.slug(slug).first?
      category
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
