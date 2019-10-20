class UserSerializer < Lucky::Serializer
  def initialize(@user : User)
  end

  def render
    {email: @user.email}
  end
end
