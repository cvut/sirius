require "bundler"
Bundler.require
require_relative "lib/initializer"
require "config/routes"

run Routes
