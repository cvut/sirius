# Logging configuration for the whole app.
#
# For details see https://github.com/TwP/logging

require 'logging'

Logging.logger.root.appenders = Logging.appenders.stdout(
  layout: Logging::Layouts.pattern(format_as: :inspect, pattern: '%-5l [%c]: %m\n')
)
Logging.logger.root.level = (ENV['RACK_ENV'] == 'production' ? :info : :debug)
