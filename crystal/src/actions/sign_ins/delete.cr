class SignIns::Delete < BrowserAction
  delete "/sign_out" do
    cache_friendly_sign_out
    flash.info = "You have been signed out"
    redirect to: SignIns::New
  end
end
