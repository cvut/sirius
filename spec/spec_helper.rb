ENV['RACK_ENV'] ||= 'test'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'sequel'

# TODO: Move this to config/boot
@config = YAML.load_file('config/database.yml')['test']
DB = Sequel.connect(@config)
DB.loggers << Logger.new("log/test.log")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'
end

def load_path(path)
  File.join(File.dirname(__FILE__), path)
end

$LOAD_PATH << load_path("..")

