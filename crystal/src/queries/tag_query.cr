class TagQuery < Tag::BaseQuery
  # Return the names of the tags that have at least one associated post
  def self.with_posts : Array(String)
    names = [] of String

    AppDatabase.run do |db|
      db.query_each "SELECT tags.name FROM tags, post_tags WHERE post_tags.tag_id = tags.id GROUP BY tags.name HAVING count(tags.name) > 0 ORDER BY tags.name;" do |result_set|
        names << result_set.read(String)
      end
    end

    names
  end
end
