source 'https://rubygems.org'

gem 'rake'

# Storage
gem 'pg'
gem 'sequel'

# REST API
gem 'grape'
gem 'roar'
gem 'json'

# Helper libs
gem 'ice_cube' # Date/Time helper
gem 'icalendar', '~> 2.0.1'

# Server
#gem 'thin'

gem 'activesupport'

group :development do
  gem 'rerun'
end

group :test do
  gem 'rspec', '~> 3.0.0.beta2'
  gem 'rack-test'
  gem 'bogus'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'fabrication'

  # Fork, until RSpec 3.0 is supported
  # https://github.com/collectiveidea/json_spec/pull/71
  gem 'json_spec', github: 'jnv/json_spec'
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'awesome_print'
  gem 'dotenv'
end

gem 'kosapi_client', github: 'flexik/kosapi_client'
