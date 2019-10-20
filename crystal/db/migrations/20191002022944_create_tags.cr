class CreateTags::V20191002022944 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Tag) do
      primary_key id : Int64
      add name : String, unique: true, index: true
    end
  end

  def rollback
    drop table_for(Tag)
  end
end
