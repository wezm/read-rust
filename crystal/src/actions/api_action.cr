# Include modules and add methods that are for all API requests
abstract class ApiAction < Lucky::Action
  accepted_formats [:json]

  include Api::Auth::Helpers

  # By default all actions require sign in.
  # Add 'include Api::Auth::SkipRequireAuthToken' to your actions to allow all requests.
  include Api::Auth::RequireAuthToken
end
