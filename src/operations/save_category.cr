class SaveCategory < Category::SaveOperation
  permit_columns name, hashtag, slug, description
end
