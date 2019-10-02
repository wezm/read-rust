class Creator < BaseModel
  table do
    column name : String
    column avatar : String
    column support_link_name : String
    column support_link_url : String
    column code_link_name : String
    column code_link_url : String
    column description : String
  end
end
