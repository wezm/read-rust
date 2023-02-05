class Creator < BaseModel
  table do
    column name : String
    column avatar : String
    column support_link_name : String
    column support_link_url : String
    column code_link_name : String
    column code_link_url : String
    column description : String
    has_many creator_tags : CreatorTag
    has_many tags : Tag, through: [:creator_tags, :tag]
  end

  def avatar_thumbnail : String
    Avatar.new(avatar).thumbnail_path.to_s
  end
end
