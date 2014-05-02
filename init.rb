# class ::Logger; alias_method :write, :<<; end # for Rack::CommonLogger
# $logger = ::Logger.new('log/service.log')

RACK_ENV = ENV['RACK_ENV'] || 'development'

puts "Starting environment: #{RACK_ENV}..."
require File.expand_path('config/boot', File.dirname(__FILE__))

require 'api/base'
require 'middleware/db_connection_sweeper'
require 'middleware/logger'
require 'logger'

class ::Logger; alias_method :write, :<<; end # for Rack::CommonLogger
$logger = ::Logger.new("log/#{RACK_ENV}.log")

# DB.loggers << $logger
