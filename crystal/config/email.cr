BaseEmail.configure do |settings|
  if Lucky::Env.production?
    # If you don't need to send emails, set the adapter to DevAdapter instead:
    #
    #   settings.adapter = Carbon::DevAdapter.new
    #
    # If you do need emails, get a key from SendGrid and set an ENV variable
    send_grid_key = send_grid_key_from_env
    settings.adapter = Carbon::SendGridAdapter.new(api_key: send_grid_key)
  else
    settings.adapter = Carbon::DevAdapter.new
  end
end

private def send_grid_key_from_env
  ENV["SEND_GRID_KEY"]? || raise_missing_key_message
end

private def raise_missing_key_message
  puts "Missing SEND_GRID_KEY. Set the SEND_GRID_KEY env variable to 'unused' if not sending emails, or set the SEND_GRID_KEY ENV var.".colorize.red
  exit(1)
end
