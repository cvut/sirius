# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require 'active_support/all'

require 'dotenv'
Dotenv.load

def load_path(path)
  File.expand_path(path, File.dirname(__FILE__))
end

$LOAD_PATH << load_path('../')
$LOAD_PATH << load_path('../lib')
$LOAD_PATH << load_path('../app')
%w(api contexts helpers representers models).each do |app_path|
  $LOAD_PATH << load_path("../app/#{app_path}")
end

# Load initializers
Dir['config/initializers/*.rb'].each {|file| require file }
