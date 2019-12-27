class TagName
  def initialize(@tag_name : String)
  end

  def format : String
    File.extname(@tag_name)
  end

  def name : String
    File.basename(@tag_name, format)
  end
end
