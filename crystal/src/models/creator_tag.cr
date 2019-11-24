class CreatorTag < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64
    belongs_to creator : Creator
    belongs_to tag : Tag
  end
end
