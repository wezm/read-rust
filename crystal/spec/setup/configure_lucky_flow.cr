# For more detailed documentation, visit
# https://luckyframework.org/guides/testing/html-and-interactivity

LuckyFlow.configure do |settings|
  settings.stop_retrying_after = 200.milliseconds
  settings.base_uri = Lucky::RouteHelper.settings.base_uri

  # LuckyFlow will install the chromedriver for you located in
  # ~./webdrivers/. Uncomment this to point to a specific driver
  # settings.driver_path = "/path/to/specific/chromedriver"
end

# By default, LuckyFlow is set in "headless" mode (no browser window shown).
# Uncomment this to enable running `LuckyFlow` in a Google Chrome window instead.
# Be sure to disable for CI.
#
# LuckyFlow.default_driver = "chrome"

# LuckyFlow uses a registry for each driver. By default, chrome, and headless_chrome
# are available. If you'd like to register your own custom driver, you can register
# it here.
#
# LuckyFlow::Registry.register :firefox do
#   # add your custom driver here
# end

# Setup specs to allow you to change the driver on the fly
# per spec by setting a tag on specific specs. Requires the
# driver to be registered through `LuckyFlow::Registry` first.
#
# ```
# it "uses headless_chrome" do
# end
# it "uses webless", tags: "webless" do
# end
# ```
LuckyFlow::Spec.setup