AppDatabase.configure do |settings|
  if Lucky::Env.production?
    settings.url = ENV.fetch("DATABASE_URL")
  elsif Lucky::Env.test?
    settings.url = ENV.fetch("TEST_DATABASE_URL")
  else
    settings.url = ENV.fetch("DATABASE_URL")
  end
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase

  # In production, allow lazy loading (N+1).
  # In development and test, raise an error if you forget to preload associations
  settings.lazy_load_enabled = Lucky::Env.production?
end
