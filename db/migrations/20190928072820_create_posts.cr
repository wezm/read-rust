class CreatePosts::V20190928072820 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Post) do
      primary_key id : Int64
      add title : String
      add url : String, unique: true
      add twitter_url : String
      add mastodon_url : String
      add author : String
      add summary : String
      add tweeted_at : Time?
      add tooted_at : Time?
      add_timestamps
    end
  end

  def rollback
    drop table_for(Post)
  end
end
