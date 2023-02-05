module Lucky::Env
  extend self

  {% for env in [:development, :test, :production] %}
    def {{ env.id }}?
      name == {{ env.id.stringify }}
    end
  {% end %}

  def name
    ENV["LUCKY_ENV"]? || "development"
  end

  # Returns true if a task is being run through the `lucky` cli
  #
  # Use this method to only run (or avoid running) code when a task is executed.
  def task?
    ENV["LUCKY_TASK"]? == "true"
  end
end
