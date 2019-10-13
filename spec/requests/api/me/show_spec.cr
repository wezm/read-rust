require "../../../spec_helper"

describe Api::Me::Show do
  it "returns the signed in user" do
    user = UserBox.create

    response = AppClient.auth(user).exec(Api::Me::Show)

    response.should send_json(200, email: user.email)
  end

  it "fails if not authenticated" do
    response = AppClient.exec(Api::Me::Show)

    response.status_code.should eq(401)
  end
end
