def load_path(path)
  File.join(File.dirname(__FILE__), path)
end

$LOAD_PATH << load_path(".")
$LOAD_PATH << load_path("./lib")

require 'api/base'
require 'middleware/db_connection_sweeper'
require 'middleware/logger'
require 'logger'

class ::Logger; alias_method :write, :<<; end # for Rack::CommonLogger
$logger = ::Logger.new('log/service.log')

RACK_ENV = ENV['RACK_ENV'] || 'development'

puts "Starting environment: #{RACK_ENV}..."
@config = YAML.load_file('config/database.yml')[RACK_ENV]

ActiveRecord::Base.establish_connection @config
ActiveRecord::Base.logger = $logger
