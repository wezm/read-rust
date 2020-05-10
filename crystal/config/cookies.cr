require "./server"

Lucky::Session.configure do |settings|
  settings.key = "_read_rust_session"
end

Lucky::CookieJar.configure do |settings|
  settings.on_set = ->(cookie : HTTP::Cookie) {
    cookie.http_only(true)

    # If ForceSSLHandler is enabled, only send cookies over HTTPS
    cookie.secure(Lucky::ForceSSLHandler.settings.enabled)

    # You can set other defaults for cookies here. For example:
    cookie.expires(1.week.from_now).domain("readrust.net")
  }
end
