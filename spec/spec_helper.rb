ENV['RACK_ENV'] = 'test'

require 'bundler'
require 'pliny/utils'

if ENV['CI'] || ENV['COVERAGE']
  require 'simplecov'
end

require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/http'
require 'fabrication'

require 'dotenv'
Dotenv.load
Dotenv.overload('.env.test')

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


