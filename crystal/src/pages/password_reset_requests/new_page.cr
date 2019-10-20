class PasswordResetRequests::NewPage < AuthLayout
  needs operation : RequestPasswordReset

  def content
    h1 "Reset your password"
    render_form(@operation)
  end

  private def render_form(op)
    form_for PasswordResetRequests::Create do
      mount Shared::Field.new(op.email), &.email_input
      submit "Reset Password", flow_id: "request-password-reset-button"
    end
  end
end
