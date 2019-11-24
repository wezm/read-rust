class SavePostCategory < PostCategory::SaveOperation
  permit_columns :post_id, :category_id

  before_save do
    validate_inclusion_of category_id, in: Category.valid_ids
  end
end
