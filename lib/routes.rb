require 'api/base'

Routes = Rack::Builder.new do
  use Pliny::Middleware::RescueErrors, raise: Config.raise_errors?
  use Pliny::Middleware::CORS
  use Rack::Timeout, service_timeout: Config.timeout if Config.timeout > 0
  use Raven::Rack if Config.sentry_dsn
  use Rack::Deflater
  use Rack::MethodOverride
  # use Rack::SSL if Config.force_ssl?

  run API::Base
end
