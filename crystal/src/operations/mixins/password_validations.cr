module PasswordValidations
  macro included
    before_save run_password_validations
  end

  private def run_password_validations
    validate_required password, password_confirmation
    validate_confirmation_of password, with: password_confirmation
    # 72 is the limit of BCrypt
    validate_size_of password, min: 6, max: 72
  end
end
