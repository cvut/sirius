# VCR config
require 'vcr'

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into :faraday
  c.default_cassette_options = {
      record: ENV['CI'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.ignore_localhost = true
end

VCR.turn_off! ignore_cassettes: true if ENV['CI']
