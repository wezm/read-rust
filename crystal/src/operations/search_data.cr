class SearchData < Avram::Operation
  attribute q : String = ""

  def run
    validate_required q

    PostQuery.search(q.value)
  end
end
