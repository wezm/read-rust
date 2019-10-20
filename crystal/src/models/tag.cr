class Tag < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64
    column name : String
    has_many creator_tags : CreatorTag
    has_many creators : Creator, through: :creator_tags
  end
end
