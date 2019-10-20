class UserBox < Avram::Box
  def initialize
    email "#{sequence("test-email")}@example.com"
    encrypted_password Authentic.generate_encrypted_password("password")
  end
end
