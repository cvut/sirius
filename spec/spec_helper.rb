ENV['RACK_ENV'] = 'test'

require "bundler"
Bundler.require(:default, :test)

require 'codeclimate-test-reporter'
require 'simplecov'
require 'coveralls'

formatters = [SimpleCov::Formatter::HTMLFormatter]

formatters << Coveralls::SimpleCov::Formatter if ENV['TRAVIS'] || ENV['COVERALLS_REPO_TOKEN']
formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
SimpleCov.start 'rails'

root = File.expand_path("../../", __FILE__)
ENV.update(Pliny::Utils.parse_env("#{root}/.env")) if File.exists?("#{root}/.env") # Load default env…
ENV.update(Pliny::Utils.parse_env("#{root}/.env.test")) # and overwrite it.

require_relative "../lib/initializer"

# pull in test initializers
Pliny::Utils.require_glob("#{Config.root}/spec/support/**/*.rb")

RSpec.configure do |config|
  config.include KOSapiClientConfigurator
  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner[:sequel, {:connection => DB}]
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

end


