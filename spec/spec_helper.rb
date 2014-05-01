RACK_ENV = ENV['RACK_ENV'] || 'test'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

# FIXME: This should go to boot, probably with load_path
# and APP_ROOT constant
require File.expand_path('../config/boot', File.dirname(__FILE__))

require 'fabrication'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir["spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |c|
  c.order = 'random'

  # Use transactions per
  # http://sequel.jeremyevans.net/rdoc/files/doc/testing_rdoc.html
  c.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
end

