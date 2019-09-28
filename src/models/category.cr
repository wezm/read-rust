class Category < BaseModel
  skip_default_columns

  table do
    primary_key id : Int16
    column name : String
    column hashtag : String
    column slug : String
    column description : String
  end
end
