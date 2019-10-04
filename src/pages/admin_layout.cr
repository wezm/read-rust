require "./main_layout"

abstract class AdminLayout < MainLayout
  def extra_css
    "css/admin.css"
  end
end
