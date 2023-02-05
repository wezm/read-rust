# For more detailed documentation, visit
# https://luckyframework.org/guides/testing/html-and-interactivity

LuckyFlow.configure do |settings|
  settings.stop_retrying_after = 200.milliseconds
  settings.base_uri = Lucky::RouteHelper.settings.base_uri

  # By default, LuckyFlow is set in "headless" mode (no browser window shown).
  # Uncomment this to enable running `LuckyFlow` in a Google Chrome window instead.
  # Be sure to disable for CI.
  # settings.driver = LuckyFlow::Drivers::Chrome
end
Spec.before_each { LuckyFlow::Server::INSTANCE.reset }
