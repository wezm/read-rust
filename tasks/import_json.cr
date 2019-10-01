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

class ImportJson < LuckyCli::Task
  summary "Imports posts from Read Rust 1.0"

  def call(io : IO = STDOUT)
    if ARGV.size < 3
      io.puts "Usage: import-json posts.json tweeted.json tooted.json"
      io.puts "E.g. lucky import_json ~/Projects/read-rust/content/_data/rust/posts.json ~/Projects/read-rust/content/_data/{tweeted,tooted}.json"
    else
      import
    end
  end

  private def import
    feed = Feed.from_json(File.read(ARGV[0]))
    tweeted = Array(Hash(String, String)).from_json(File.read(ARGV[1])).map { |obj| obj["item_id"] }.to_set
    tooted = Array(Hash(String, String)).from_json(File.read(ARGV[2])).map { |obj| obj["item_id"] }.to_set

    categories = CategoryQuery.all.each_with_object({} of String => Int64) do |category, hash|
      hash[category.name] = category.id
    end

    AppDatabase.transaction do
      feed.items.each do |post|
        puts post.title
        created_post = SavePost.create!(
          title: post.title,
          url: post.url,
          twitter_url: post.tweet_url,
          mastodon_url: nil,
          author: post.author.name,
          summary: post.content_text,
          #published_at: post.date_published,
          tweeted_at: tweeted.includes?(post.id) ? Time.utc : nil,
          tooted_at: tooted.includes?(post.id) ? Time.utc : nil,
        )
        post.tags.each do |category_name|
          SavePostCategory.create!(post_id: created_post.id, category_id: categories[category_name])
        end
      end

      true
    end
  end
end
