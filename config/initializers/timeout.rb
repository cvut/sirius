require 'rack-timeout'

if Config.rack_timeout > 0
  Rack::Timeout.timeout = Config.rack_timeout
end
