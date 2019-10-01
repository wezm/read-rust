class Post < BaseModel
  table do
    column title : String
    column url : String
    column twitter_url : String?
    column mastodon_url : String?
    column author : String
    column summary : String
    column tweeted_at : Time?
    column tooted_at : Time?
  end
end
