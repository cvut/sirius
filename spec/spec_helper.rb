ENV['RACK_ENV'] ||= 'test'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

def load_path(path)
  File.join(File.dirname(__FILE__), path)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["../spec/support/**/*.rb"].each { |f| require f }

# FIXME: This should go to boot, probably with load_path
# and APP_ROOT constant
$LOAD_PATH << load_path("..")

require 'config/boot'

RSpec.configure do |config|
  config.order = 'random'
end

