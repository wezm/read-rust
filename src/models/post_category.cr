class PostCategory < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64
    belongs_to post : Post
    belongs_to category : Category
  end
end
