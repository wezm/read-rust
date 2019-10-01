class Category < BaseModel
  skip_default_columns

  table do
    primary_key id : Int64
    column name : String
    column hashtag : String
    column slug : String
    column description : String
  end
end
