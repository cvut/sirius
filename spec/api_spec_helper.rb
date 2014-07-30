require 'rack/test'
require 'json_spec'
require 'spec_helper'
# require 'support/rack_helper'

require 'api/base'

RSpec.configure do |config|
  config.include RackHelper
  config.include JsonSpec::Helpers
end
