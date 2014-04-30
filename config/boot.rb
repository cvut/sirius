# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require 'active_support/all'

# Setup DB connection
require 'yaml'
require 'sequel'
db_config = YAML.load_file('config/database.yml')[ENV['RACK_ENV']]
DB = Sequel.connect(db_config)
