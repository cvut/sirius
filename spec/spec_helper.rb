ENV['RACK_ENV'] = 'test'

require "bundler"
Bundler.require(:default, :test)

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

root = File.expand_path("../../", __FILE__)
ENV.update(Pliny::Utils.parse_env("#{root}/.env.test"))

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


