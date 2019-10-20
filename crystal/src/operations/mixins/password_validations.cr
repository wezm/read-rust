module PasswordValidations
  macro included
    before_save run_password_validations
  end

  private def run_password_validations
    validate_required password, password_confirmation
    validate_confirmation_of password, with: password_confirmation
    validate_size_of password, min: 6
  end
end
