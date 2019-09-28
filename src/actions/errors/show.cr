class Errors::Show < Lucky::ErrorAction
  def handle_error(error : JSON::ParseException)
    message = "There was a problem parsing the JSON." +
              " Please check that it is formed correctly"

    if json?
      json Errors::ShowSerializer.new(message), status: 400
    else
      render_error_page status: 500
    end
  end

  def handle_error(error : Lucky::RouteNotFoundError)
    if json?
      json Errors::ShowSerializer.new("Not found"), status: 404
    else
      render_error_page title: "Sorry, we couldn't find that page.", status: 404
    end
  end

  # This is the catch all method that renders unhandled exceptions
  def handle_error(error : Exception) : Lucky::Response
    Lucky.logger.error(unhandled_error: error.inspect_with_backtrace)

    if Lucky::ErrorHandler.settings.show_debug_output
      # In development and test, render a debug page
      render_detailed_exception_page(error)
    else
      # Otherwise render a nice looking error for users
      render_unhandled_error(error)
    end
  end

  private def render_detailed_exception_page(error)
    Lucky::ErrorHandler.render_exception_page(context, error)
  end

  private def render_unhandled_error(error)
    message = "An unexpected error occurred"

    if json?
      json Errors::ShowSerializer.new(message), status: 500
    else
      render_error_page status: 500
    end
  end

  private def render_error_page(status : Int32, title : String = "We're sorry. Something went wrong.")
    context.response.status_code = status
    render Errors::ShowPage, status: status, title: title
  end
end
