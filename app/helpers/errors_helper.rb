module ErrorsHelper
  def rescue_status(error_type, error_status)
    rescue_from error_type do |e|
      msg = { message: e.message, status: error_status }
      error_response(message: msg, status: error_status)
    end
  end
end
