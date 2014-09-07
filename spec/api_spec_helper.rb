require 'rack/test'
require 'json_spec'
require 'spec_helper'
require 'url_helper'
require 'api/base'
require 'warden'

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
  config.include UrlHelper
  config.include Warden::Test::Helpers

  config.after(:each) { Warden.test_reset! }
end
