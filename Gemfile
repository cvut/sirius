source 'https://rubygems.org'
ruby '2.1.2'
gem 'rake'

# Storage
gem 'pg'
gem 'sequel'
gem 'sequel_pg'

# REST API
gem 'grape'
gem 'roar', github: 'apotonick/roar'
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
  gem 'pry-nav', '~> 0.2.4', require: false
  gem 'awesome_print'
  gem 'dotenv'
end


group :documentation do
  gem 'kramdown'
  gem 'guard-livereload'
  gem 'guard-yard'
end

gem 'kosapi_client', github: 'cvut/kosapi_client.rb'
