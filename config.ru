require 'bundler'
Bundler.require
require_relative 'lib/initializer'
require 'config/routes'

$stdout.sync = true

run Routes
