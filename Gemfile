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
gem 'icalendar', '~> 2.1.0'

# Server
#gem 'thin'

gem 'activesupport'

gem 'role_playing'

group :development do
  gem 'rerun'
end

group :test do
  gem 'rspec', '~> 3.0.0'
  gem 'rack-test'
  gem 'bogus'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'fabrication'

  gem 'json_spec', '~> 1.1.2'
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'awesome_print'
  gem 'dotenv'
end

gem 'kosapi_client', github: 'flexik/kosapi_client'
