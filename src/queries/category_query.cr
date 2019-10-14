class CategoryQuery
  include Enumerable(Category)

  def each
    Category::ALL.each do |category|
      yield category
    end
  end

  def slug(slug)
    Category::ALL.select { |category| category.slug == slug }
  end
end
