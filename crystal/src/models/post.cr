class Post < BaseModel
  table do
    column guid : UUID
    column title : String
    column url : String
    column twitter_url : String?
    column mastodon_url : String?
    column author : String
    column summary : String
    column tweeted_at : Time?
    column tooted_at : Time?
    has_many post_categories : PostCategory
    has_many post_tags : PostTag
    has_many tags : Tag, through: [:post_tags, :tag]
  end
end
