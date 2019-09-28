class SavePost < Post::SaveOperation
  permit_columns title, url, twitter_url, mastodon_url, author, summary, tweeted_at, tooted_at
end
