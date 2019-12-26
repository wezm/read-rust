class Tags::Show < BrowserAction
  include Auth::AllowGuests

  before cache_in_varnish(2.minutes)

  get "/tags/:tag_name" do
    tag = TagQuery.new.name(tag_name).first
    posts = PostQuery.new.preload_post_categories.preload_tags.where_post_tags(PostTagQuery.new.tag_id(tag.id)).created_at.desc_order
    weak_etag(last_modified(tag).to_unix)

    html ShowPage, tag: tag, posts: posts
  end

  private def last_modified(tag)
    PostQuery.new.where_post_tags(PostTagQuery.new.tag_id(tag.id)).updated_at.select_max
  rescue TypeCastError
    # Workaround error: cast from Nil to Time failed
    # originating in Avram
    # https://github.com/luckyframework/avram/pull/287
    Time.utc
  end
end
