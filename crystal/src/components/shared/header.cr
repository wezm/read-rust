class Shared::Header < BaseComponent
  needs current_user : User?
  needs query : String = ""

  def render
    current_user = @current_user

    header do
      div class: "logo-search-header #{@query.blank? ? "" : "logo-search-header-with-query"}" do
        link to: Home::Index do
          img alt: "", class: "logo", src: asset("images/logo.svg")
          text "Read Rust"
        end

        mount Search::Form.new(@query)
      end

      nav do
        div class: "list-inline" do
          div do
            link "Home", to: Home::Index
          end
          div do
            link "About", to: About::Show
          end
          if current_user
            div do
              link "Submit", to: Posts::New
            end
          else
            div do
              link "Submit", to: Submit::Show
            end
          end
          div class: "support" do
            link "Support Rust", class: "heart", to: Creators::Index
          end
          if current_user
            render_signed_in_user(current_user)
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
