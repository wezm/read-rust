abstract class BaseModel < Avram::Model
  def self.database
    AppDatabase
  end
end
