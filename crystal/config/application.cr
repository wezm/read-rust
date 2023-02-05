# This file may be used for custom Application configurations.
# It will be loaded before other config files.
#
# Read more on configuration:
#   https://luckyframework.org/guides/getting-started/configuration#configuring-your-own-code

# Use this code as an example:
#
# ```
# module Application
#   Habitat.create do
#     setting support_email : String
#     setting lock_with_basic_auth : Bool
#   end
# end
#
# Application.configure do |settings|
#   settings.support_email = "support@myapp.io"
#   settings.lock_with_basic_auth = LuckEnv.staging?
# end
#
# # In your application, call
# # `Application.settings.support_email` anywhere you need it.
# ```