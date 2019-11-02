class Shared::Header < BaseComponent
  needs current_user : User?

  def render
    header do
      link to: Home::Index do
        text "Read "
        img alt: "", class: "logo", src: asset("images/logo.svg")
        text " Rust"
      end
      nav do
        div class: "list-inline" do
          div do
            link "Home", to: Home::Index
          end
          div do
            link "About", to: About::Show
          end
          div do
            link "Submit", to: Submit::Show
          end
          div class: "support" do
            link "Support Rust", class: "heart", to: Creators::Index
          end
          @current_user.try do |user|
            render_signed_in_user(user)
          end
        end
      end
    end
  end

  private def render_signed_in_user(user)
    div do
      link "Sign out", to: SignIns::Delete, flow_id: "sign-out-button"
    end
  end
end
