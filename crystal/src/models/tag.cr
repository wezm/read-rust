class Tag < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64
    column name : String
    has_many creator_tags : CreatorTag
    has_many creators : Creator, through: :creator_tags
    has_many post_tags : PostTag
    has_many posts : Post, through: :post_tags
  end
end
