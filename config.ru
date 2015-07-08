require 'bundler'
Bundler.require
require_relative 'lib/initializer'
require 'lib/routes'

$stdout.sync = true

run Routes
