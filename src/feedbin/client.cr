module Feedbin
  class ExtractedArticle
    JSON.mapping(
      url: String,
      title: String?,
      host: String?,
      author: String?,
      content: String?,
    )
  end

  class Entry
    JSON.mapping(
      id: Int64,
      feed_id: Int64,
      title: String?,
      content: String?,
      url: String,
      twitter_id: UInt64?,
      author: String?,
      summary: String, # Might be a blank string...
      published: Time,
      extracted_articles: Array(ExtractedArticle),
    )
  end

  class Client
    def initialize(@username : String, @password : String)
    end

    def entry(id : UInt64) : Entry
      url = UrlBuilder.url("/entries/3648.json", {mode: "extended"})
      # TODO Reuse client?
      client = HTTP::Client.new url.host.not_nil!
      client.basic_auth(@username, @password)
      resp = client.get url.full_path do |resp|
        # TODO: Check status?
        Entry.from_json(resp.body_io)
      end
    end
  end

  class UrlBuilder
    def self.url(path : String, query : NamedTuple? = nil) : URI
      query_params = query.try { |params| HTTP::Params.encode(params) }
      URI.new("https", "api.feedbin.com", nil, "/v2#{path}", query_params)
    end
  end
end
