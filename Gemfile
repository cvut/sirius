source 'https://rubygems.org'

gem 'rake'

# Storage
gem 'pg'
gem 'sequel'

# REST API
gem 'grape'
gem 'roar'
gem 'json'

# Time & Space
gem 'ice_cube' # Date/Time helper
gem 'icalendar', '~> 2.1.0'

# Helper stuff
gem 'activesupport'
gem 'role_playing'

group :development do
  gem 'guard-shotgun', github: 'jnv/guard-shotgun', require: false
  gem 'guard-rspec', require: false
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
  gem 'vcr'
end

group :development, :test do
  gem 'pry', '~> 0.10.0', require: false
  gem 'pry-nav', github: 'nixme/pry-nav', require: false
  gem 'awesome_print'
  gem 'dotenv'
end


group :documentation do
  gem 'kramdown'
  gem 'guard-livereload'
  gem 'guard-yard'
end

gem 'kosapi_client', github: 'flexik/kosapi_client'
