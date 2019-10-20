class ImportPost < Post::SaveOperation
  permit_columns guid, title, url, twitter_url, mastodon_url, author, summary, tweeted_at, tooted_at, created_at
end
