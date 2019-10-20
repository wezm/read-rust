class ErrorSerializer < BaseSerializer
  def initialize(
    @message : String,
    @details : String? = nil,
    @param : String? = nil # If there was a problem with a specific param
  )
  end

  def render
    {message: @message, param: @param, details: @details}
  end
end
