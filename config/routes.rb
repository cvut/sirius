require 'api/base'

Routes = Rack::Builder.new do
  use Pliny::Middleware::RescueErrors, raise: Config.raise_errors?
  use Pliny::Middleware::CORS
  use Pliny::Middleware::Timeout, timeout: Config.timeout.to_i if Config.timeout.to_i > 0
  use Rack::Deflater
  use Rack::MethodOverride
  # use Rack::SSL if Config.force_ssl?

  run API::Base
end
