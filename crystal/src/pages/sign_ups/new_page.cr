class SignUps::NewPage < AuthLayout
  needs operation : SignUpUser
  quick_def page_title, "Sign Up"
  quick_def page_description, ""

  def content
    h1 "Sign Up"
    render_sign_up_form(@operation)
  end

  private def render_sign_up_form(op)
    form_for SignUps::Create, class: "form-stacked" do
      sign_up_fields(op)

      div do
        submit "Sign Up", flow_id: "sign-up-button"
      end
    end
    link "Sign in instead", to: SignIns::New
  end

  private def sign_up_fields(op)
    mount Shared::Field.new(op.email), &.email_input(autofocus: "true")
    mount Shared::Field.new(op.password), &.password_input
    mount Shared::Field.new(op.password_confirmation), &.password_input
  end
end
