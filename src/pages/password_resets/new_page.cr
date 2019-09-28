class PasswordResets::NewPage < AuthLayout
  needs operation : ResetPassword
  needs user_id : Int32

  def content
    h1 "Reset your password"
    render_password_reset_form(@operation)
  end

  private def render_password_reset_form(op)
    form_for PasswordResets::Create.with(@user_id) do
      mount Shared::Field.new(op.password), &.password_input(autofocus: "true")
      mount Shared::Field.new(op.password_confirmation), &.password_input

      submit "Update Password", flow_id: "update-password-button"
    end
  end
end
