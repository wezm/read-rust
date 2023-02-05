class AppServer < Lucky::BaseAppServer
  def middleware : Array(HTTP::Handler)
    [
      Lucky::RequestIdHandler.new,
      Lucky::ForceSSLHandler.new,
      Lucky::HttpMethodOverrideHandler.new,
      Lucky::LogHandler.new,
      Lucky::ErrorHandler.new(action: Errors::Show),
      Lucky::RemoteIpHandler.new,
      Lucky::RouteHandler.new,
      Lucky::StaticCompressionHandler.new("./public", file_ext: "gz", content_encoding: "gzip"),
      Lucky::StaticFileHandler.new("./public", fallthrough: false, directory_listing: false),
      Lucky::RouteNotFoundHandler.new,
    ] of HTTP::Handler
  end

  def protocol
    "http"
  end

  def listen
    server.listen(host, port, reuse_port: false)
  end
end
