class SearchData < Avram::Operation
  attribute q : String = ""

  def submit
    validate_required q

    yield self, PostQuery.search(q.value)
  end
end
