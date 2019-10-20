class CreatorBox < Avram::Box
  def initialize
    name "Test Creator"
    avatar "test.jpg"
    support_link_name "Support on Patreon"
    support_link_url "http://example.com/support"
    code_link_name "test"
    code_link_url "http://example.com/code/test"
    description "Description"
  end
end
