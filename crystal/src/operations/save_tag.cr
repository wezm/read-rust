class SaveTag < Tag::SaveOperation
  before_save validate_size_of name, max: 25
end
