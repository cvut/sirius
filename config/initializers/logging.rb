# Logging configuration for the whole app.
#
# For details see https://github.com/TwP/logging

require 'logging'

Logging.logger.root.tap do |root|
  root.appenders = Logging.appenders.stdout(
    layout: Logging::Layouts.pattern(format_as: :inspect, pattern: '%-5l [%c]: %m\n')
  )
  root.level = (Config.rack_env == 'development' ? :debug : :info)
end
