class SaveTag < Tag::SaveOperation
  before_save validate_size_of name, max: 25
  before_save validate_name

  private def validate_name
    if (name.value || "").strip.downcase !~ /\A[a-z][a-z0-9-]*\z/
      name.add_error "must only contain a-z, 0-9, or hyphen"
    end
  end
end
