class SavePost < Post::SaveOperation
  permit_columns title, url, twitter_url, mastodon_url, author, summary

  # TODO: Automatically populate guid before save
  before_save assign_guid

  private def assign_guid
    guid.value ||= UUID.random
  end
end
