ENV['RACK_ENV'] = 'test'

require 'bundler'
require 'pliny/utils'

root = File.expand_path("../../", __FILE__)
ENV.update(Pliny::Utils.parse_env("#{root}/.env")) if File.exists?("#{root}/.env") # Load default env…
ENV.update(Pliny::Utils.parse_env("#{root}/.env.test")) # and overwrite it.

require 'simplecov'
require 'rspec'
require 'fabrication'

require_relative "../lib/initializer"

# pull in test initializers
Pliny::Utils.require_glob("#{Config.root}/spec/support/**/*.rb")

RSpec.configure do |config|
  config.include KOSapiClientConfigurator
  config.order = 'random'

  config.before(:suite) do
    require 'database_cleaner'
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


