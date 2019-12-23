class SavePost < Post::SaveOperation
  permit_columns title, url, twitter_url, mastodon_url, author, summary

  attribute tags : String

  before_save assign_guid
  before_save validate_tags

  private def assign_guid
    guid.value ||= UUID.random
  end

  private def validate_tags
    if (tags.value || "").strip.downcase !~ /\A[ a-z-]*\z/
      tags.add_error "must be space separated and only contain a-z or hyphen"
    end
  end
end
