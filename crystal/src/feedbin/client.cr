module Feedbin
  class Error < Exception
  end

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

    def twitter?
      !twitter_id.nil?
    end
  end

  class Client
    Habitat.create do
      setting username : String
      setting password : String
    end

    def entry(id : UInt64) : Entry
      url = UrlBuilder.url("/entries/#{id}.json", {mode: "extended"})
      # TODO Reuse client?
      client = HTTP::Client.new url.host.not_nil!, tls: true
      client.basic_auth(settings.username, settings.password)
      resp = client.get url.full_path do |resp|
        # TODO: handle redirects
        if resp.success?
          Entry.from_json(resp.body_io)
        else
          raise Error.new("Unsuccessful response from Feedbin [#{resp.status_code}]")
        end
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
