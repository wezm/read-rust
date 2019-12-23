class CreatePostTags::V20191223012953 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(PostTag) do
      primary_key id : Int64
      add_belongs_to post : Post, on_delete: :cascade
      add_belongs_to tag : Tag, on_delete: :cascade
    end

    create_index table_for(PostTag), [:post_id, :tag_id], unique: true
  end

  def rollback
    drop table_for(PostTag)
  end
end
