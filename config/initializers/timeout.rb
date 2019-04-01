require 'rack-timeout'

if Config.timeout > 0
  Rack::Timeout.timeout = Config.timeout
  Rack::Timeout::Logger.level = Logger::WARN
end
