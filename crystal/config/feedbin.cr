Feedbin::Client.configure do |settings|
  settings.username = feedbin_user_from_env
  settings.password = feedbin_pass_from_env
end

private def feedbin_user_from_env
  ENV["FEEDBIN_USERNAME"]? || warn_missing_credentials
end

private def feedbin_pass_from_env
  ENV["FEEDBIN_PASSWORD"]? || warn_missing_credentials
end

private def warn_missing_credentials
  puts "FEEDBIN_USERNAME and/or FEEDBIN_PASSWORD are not set, Feedbin integration won't work".colorize.red
  ""
end
