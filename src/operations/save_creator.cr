class SaveCreator < Creator::SaveOperation
  permit_columns name, avatar, support_link_name, support_link_url, code_link_name, code_link_url, description
end
