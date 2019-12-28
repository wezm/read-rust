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
      mount Shared::LayoutHead.new(page_title: page_title, page_description: "", context: @context, categories: CategoryQuery.new, app_js: false, admin: false, extra_css: extra_css)

      body do
        mount Shared::Header.new(nil)

        main class: "main" do
          mount Shared::FlashMessages.new(@context.flash)
          content
        end
      end
    end
  end
end
