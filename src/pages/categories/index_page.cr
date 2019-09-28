class Categories::IndexPage < MainLayout
  needs categories : CategoryQuery

  def content
    ul class: "my-user-list" do
      @categories.each do |category|
        li category.name, class: "user-name"
      end
    end
  end
end
