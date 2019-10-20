require "./server"

Authentic.configure do |settings|
  settings.secret_key = Lucky::Server.settings.secret_key_base

  unless Lucky::Env.production?
    fastest_encryption_possible = 4
    settings.encryption_cost = fastest_encryption_possible
  end
end
