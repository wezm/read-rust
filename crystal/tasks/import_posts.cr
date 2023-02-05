require "json_mapping"

class Author
  JSON.mapping(
    name: String,
    url: String,
  )
end

class Item
  JSON.mapping(
    id: String,
    title: String,
    content_text: String,
    url: String,
    tweet_url: String?,
    date_published: Time,
    author: Author,
    tags: Array(String),
  )
end

class Feed
  JSON.mapping(items: Array(Item))
end

class ImportPosts < LuckyTask::Task
  summary "Imports posts from Read Rust 1.0"

  def call(io : IO = STDOUT)
    if ARGV.size < 3
      io.puts "Usage: lucky import_posts posts.json tweeted.json tooted.json"
      io.puts "E.g. lucky import_posts ~/Projects/read-rust/content/_data/rust/posts.json ~/Projects/read-rust/content/_data/{tweeted,tooted}.json"
    else
      import
    end
  end

  private def import
    feed = Feed.from_json(File.read(ARGV[0]))
    tweeted = Array(Hash(String, String)).from_json(File.read(ARGV[1])).map { |obj| obj["item_id"] }.to_set
    tooted = Array(Hash(String, String)).from_json(File.read(ARGV[2])).map { |obj| obj["item_id"] }.to_set

    categories = Category::ALL.each_with_object({} of String => Int16) do |category, hash|
      hash[category.name] = category.id
    end

    AppDatabase.transaction do
      # Import in reverse order do they're loaded oldest first and get sensisble ids
      feed.items.reverse_each do |post|
        puts post.title
        created_post = ImportPost.create!(
          guid: UUID.new(post.id, UUID::Variant::RFC4122, UUID::Version::V4),
          title: post.title,
          url: post.url,
          twitter_url: post.tweet_url,
          mastodon_url: nil,
          author: post.author.name,
          summary: post.content_text,
          # published_at: post.date_published,
          tweeted_at: tweeted.includes?(post.id) ? Time.utc : nil,
          tooted_at: tooted.includes?(post.id) ? Time.utc : nil,
          created_at: post.date_published,
        )
        post.tags.each do |category_name|
          next if category_name == "async"
          SavePostCategory.create!(post_id: created_post.id, category_id: categories[category_name])
        end
      end

      true
    end
  end
end
