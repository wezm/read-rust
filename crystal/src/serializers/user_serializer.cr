class UserSerializer < BaseSerializer
  def initialize(@user : User)
  end

  def render
    {email: @user.email}
  end
end
