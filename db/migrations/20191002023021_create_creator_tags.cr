class CreateCreatorTags::V20191002023021 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(CreatorTag) do
      primary_key id : Int64
      add_belongs_to creator : Creator, on_delete: :cascade
      add_belongs_to tag : Tag, on_delete: :cascade
    end

    create_index table_for(CreatorTag), [:creator_id, :tag_id], unique: true
  end

  def rollback
    drop table_for(CreatorTag)
  end
end
