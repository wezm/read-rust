class CreateCreators::V20191001085754 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Creator) do
      primary_key id : Int64
      add name : String
      add avatar : String
      add support_link_name : String
      add support_link_url : String
      add code_link_name : String
      add code_link_url : String
      add description : String
      add_timestamps
    end
  end

  def rollback
    drop table_for(Creator)
  end
end
