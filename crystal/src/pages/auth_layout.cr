abstract class AuthLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  def extra_css
    "css/admin.css"
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead, page_title: page_title, page_description: "", context: @context, categories: CategoryQuery.new, app_js: false, admin: false, extra_css: extra_css

      body do
        mount Shared::Header, nil

        main class: "main" do
          mount Shared::FlashMessages, @context.flash
          content
        end
      end
    end
  end
end
