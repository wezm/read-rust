class PostBox < Avram::Box
  def initialize
    guid UUID.random(Random.new, UUID::Variant::RFC4122, UUID::Version::V4)
    title "Test"
    url "https://example.com/"
    author "Test Suite"
    summary "Summary"
  end
end
