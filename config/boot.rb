# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require 'active_support/all'


def load_path(path)
  File.expand_path(path, File.dirname(__FILE__))
end

$LOAD_PATH << load_path('../')
$LOAD_PATH << load_path('../lib')
$LOAD_PATH << load_path('../app')
# %w(context data decorators helpers information representers).each do |app_path|
#   $LOAD_PATH << load_path("../app/#{app_path}")
# end


# Setup DB connection
require 'yaml'
require 'sequel'
db_config = YAML.load_file('config/database.yml')[ENV['RACK_ENV']]
DB = Sequel.connect(db_config)
