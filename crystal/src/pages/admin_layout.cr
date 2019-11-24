require "./main_layout"

abstract class AdminLayout < MainLayout
  def admin_js?
    true
  end
end
