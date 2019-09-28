class CreatePostCategories::V20190928074838 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(PostCategory) do
      primary_key id : Int64
      add_belongs_to post : Post, on_delete: :cascade
      add_belongs_to category : Category, on_delete: :cascade, foreign_key_type: Int16
    end

    create_index table_for(PostCategory), [:post_id, :category_id], unique: true
  end

  def rollback
    drop table_for(PostCategory)
    #drop_index table_for(PostCategory), [:post_id, :category_id]
  end
end
