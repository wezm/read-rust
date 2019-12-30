class Feedbin::Show < BrowserAction
  SKIP_DOMAINS = ["twitter.com", "github.com"]

  get "/feedbin/entries/:entry_id" do
    json render_entry(fetch_entry(entry_id.to_u64))
  end

  private def render_entry(entry : Feedbin::Entry) : Hash(String, String)
    # Determine if this is a Twitter entry
    if entry.twitter?
      render_twitter_entry(entry)
    else
      render_link_entry(entry)
    end
  end

  private def fetch_entry(id : UInt64) : Feedbin::Entry
    Feedbin::Client.new.entry(id)
  end

  private def render_link_entry(entry : Feedbin::Entry) : Hash(String, String)
    prefill_data = {
      "post:url" => entry.url,
    }

    add_field_if_present(prefill_data, "post:title", entry.title)
    add_field_if_present(prefill_data, "post:author", entry.author)
    add_field_if_present(prefill_data, "post:summary", entry.content.try { |content| Sanitise.strip_tags(content) })

    prefill_data
  end

  private def render_twitter_entry(entry : Feedbin::Entry) : Hash(String, String)
    # determine what will be used as the article url
    extracted_article = entry.extracted_articles.find do |extracted_article|
      !SKIP_DOMAINS.includes?(extracted_article.host)
    end

    if extracted_article.nil?
      return {"post:url" => entry.url}
    end

    prefill_data = {
      "post:url" => extracted_article.url,
    }

    add_field_if_present(prefill_data, "post:title", extracted_article.title)
    add_field_if_present(prefill_data, "post:author", extracted_article.author || entry.author)
    summary = extracted_article.content.try { |content| Sanitise.strip_tags(content) }
    add_field_if_present(prefill_data, "post:summary", summary)

    # Need to resolve this into a status?
    # "https://twitter.com/#{user}/status/#{entry.twitter_id}"
    prefill_data["post:twitter_url"] = entry.url

    prefill_data
  end

  private def add_field_if_present(data : Hash(String, String), field : String, maybe_value : String?)
    value = maybe_value.try(&.strip)
    unless value.blank?
      data[field] = value.not_nil! # safe due to check above
    end
  end
end
