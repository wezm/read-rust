Feedbin::Client.configure do |settings|
  settings.username = feedbin_user_from_env
  settings.password = feedbin_pass_from_env
end

private def feedbin_user_from_env
  ENV["FEEDBIN_USERNAME"]? || raise_missing_credentials
end

private def feedbin_pass_from_env
  ENV["FEEDBIN_PASSWORD"]? || raise_missing_credentials
end

private def raise_missing_credentials
  puts "Please set the FEEDBIN_PASSWORD and FEEDBIN_PASSWORD environment variables.".colorize.red
  exit(1)
end
