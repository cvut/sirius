source 'https://rubygems.org'

gem 'rake'

# Storage
gem 'pg'
gem 'sequel'

# REST API
gem 'grape'
gem 'roar'
gem 'json'                          # JSON

# Helper libs
gem 'ice_cube' # Date/Time helper

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
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'awesome_print'
end
