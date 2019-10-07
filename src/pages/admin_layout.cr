require "./main_layout"

abstract class AdminLayout < MainLayout
  def admin_js?
    true
  end

  def extra_css
    "css/admin.css"
  end
end
