require 'raven'
Raven.configure do |config|
  config.dsn = Config.sentry_dsn
end
