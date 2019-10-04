class SavePostCategory < PostCategory::SaveOperation
  permit_columns :post_id, :category_id
end
