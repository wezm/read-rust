class Categories::ShowPage < MainLayout
  needs category : Category
  quick_def page_title, @category.name

  def content
  end
end
