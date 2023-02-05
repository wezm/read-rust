class ApiClient < Lucky::BaseHTTPClient
  def initialize
    super
    headers("Content-Type": "application/json")
  end

  def self.auth(user : User)
    new.headers("Authorization": UserToken.generate(user))
  end
end
