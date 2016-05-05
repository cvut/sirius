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
  c.filter_sensitive_data('<AUTHORIZATION>') do |interaction|
    interaction.request.headers['Authorization'].first
  end
  c.filter_sensitive_data('<OAUTH_TOKEN>') do |interaction|
    if interaction.request.uri.include?('oauth/token') && interaction.response.status.code == 200
      JSON.parse(interaction.response.body)["access_token"]
    end
  end
end

VCR.turn_off! ignore_cassettes: true if ENV['CI']
