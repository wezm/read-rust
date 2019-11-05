require "carbon_smtp_adapter"

BaseEmail.configure do |settings|
  if Lucky::Env.production?
    Carbon::SmtpAdapter.configure do |settings|
      settings.host = value_from_env("SMTP_HOST")
      settings.port = ENV["SMTP_PORT"]?.try(&.to_i32) || 25
      # settings.helo_domain = nil
      # settings.use_tls = true
      settings.username = value_from_env("SMTP_USERNAME")
      settings.password = value_from_env("SMTP_PASSWORD")
    end

    settings.adapter = Carbon::SmtpAdapter.new
  else
    settings.adapter = Carbon::DevAdapter.new
  end
end

private def value_from_env(key)
  ENV[key]? || raise_missing_key_message(key)
end

private def raise_missing_key_message(key)
  puts "#{key} is not set, required for email".colorize.red
  exit(1)
end
