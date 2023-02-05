require "../../../spec_helper"

describe Api::SignIns::Create do
  it "returns a token" do
    UserToken.stub_token("fake-token") do
      user = UserBox.create

      response = ApiClient.exec(Api::SignIns::Create, user: valid_params(user))

      response.should send_json(200, token: "fake-token")
    end
  end

  it "returns an error if credentials are invalid" do
    user = UserBox.create
    invalid_params = valid_params(user).merge(password: "incorrect")

    response = ApiClient.exec(Api::SignIns::Create, user: invalid_params)

    response.should send_json(
      400,
      param: "password",
      details: "password is wrong"
    )
  end
end

private def valid_params(user : User)
  {
    email:    user.email,
    password: "password",
  }
end
