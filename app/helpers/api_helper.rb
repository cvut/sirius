##
# Helper methods used in Grape's API endpoints.
module ApiHelper
  def api_format
    env['api.format'].to_sym
  end

  def authenticate!
    env['warden'].authenticate!
  end
end
