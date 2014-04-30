module RackHelper
  include Rack::Test::Methods

  def app
    API::Base
  end

  alias_method :response, :last_response
end
