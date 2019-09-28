app_server = AppServer.new

spawn do
  app_server.listen
end

at_exit do
  LuckyFlow.shutdown
  app_server.close
end
