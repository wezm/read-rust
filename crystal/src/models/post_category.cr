class PostCategory < BaseModel
  skip_default_columns
  delegate slug, name, to: category

  table do
    primary_key id : Int64
    belongs_to post : Post
    column category_id : Int16
  end

  def category : Category
    Category::ALL.find { |cat| cat.id == category_id }.not_nil!
  end
end
