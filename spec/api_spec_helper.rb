require 'rack/test'
require 'json_spec'
require 'spec_helper'

require 'api/base'

module RackHelper
  include Rack::Test::Methods

  def app
    API::Base
  end

  alias_method :response, :last_response
end


RSpec.configure do |config|
  config.include RackHelper
  config.include JsonSpec::Helpers
end
