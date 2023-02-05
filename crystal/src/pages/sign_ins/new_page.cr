class SignIns::NewPage < AuthLayout
  needs operation : SignInUser
  quick_def page_title, "Sign In"
  quick_def page_description, ""

  def content
    h1 "Sign In"
    render_sign_in_form(@operation)
  end

  private def render_sign_in_form(op)
    form_for SignIns::Create, class: "form-stacked" do
      sign_in_fields(op)

      div do
        submit "Sign In", flow_id: "sign-in-button"
      end
    end
    link "Reset password", to: PasswordResetRequests::New
    if ReadRust::Config.allow_sign_up?
      text " | "
      link "Sign up", to: SignUps::New
    end
  end

  private def sign_in_fields(op)
    mount Shared::Field, op.email, &.email_input(autofocus: "true")
    mount Shared::Field, op.password, &.password_input
  end
end
