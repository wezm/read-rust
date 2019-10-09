app_server = AppServer.new

spawn do
  app_server.listen
end

Spec.after_suite do
  LuckyFlow.shutdown
  app_server.close
end
