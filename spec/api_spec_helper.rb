require 'rack/test'
require 'spec_helper'

require 'support/rack_helper'

require 'api/base'

RSpec.configure do |config|
  config.include RackHelper
end
