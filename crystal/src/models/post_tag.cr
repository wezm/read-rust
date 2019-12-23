class PostTag < BaseModel
  skip_default_columns
  delegate name, to: tag

  table do
    primary_key id : Int64
    belongs_to post : Post
    belongs_to tag : Tag
  end
end
