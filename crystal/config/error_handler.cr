Lucky::ErrorHandler.configure do |settings|
  settings.show_debug_output = !LuckyEnv.production?
end
