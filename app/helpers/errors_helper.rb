module ErrorsHelper
  def rescue_status(error_type, error_status, **options)
    rescue_from error_type do |e|
      message = options[:message] || e.message
      body = { message: message, status: error_status }
      error_response(message: body, status: error_status)
    end
  end
end
