class CreateCategories::V20190928070750 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Category) do
      primary_key id : Int32
      add name : String
      add hashtag : String, unique: true
      add slug : String, unique: true, index: true
      add description : String
    end
  end

  def rollback
    drop table_for(Category)
  end
end
