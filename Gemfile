source 'https://rubygems.org'

gem 'rake', '~> 10.5'

## Storage
gem 'pg', '~> 1.0'
gem 'sequel', '~> 4.17'
gem 'sequel_pg', '~> 1.6', require: 'sequel'
gem 'kosapi_client', '~> 0.13.0'
gem 'chewy', '~> 0.8.2', '< 0.8.4'  # 0.8.4 is broken
gem 'elasticsearch', '~> 1.0', require: false

## REST API
gem 'pliny', '~> 0.17.0'
gem 'dotenv'
gem 'grape', '~> 1.1.0'
gem 'warden', '~> 1.2.3' # authentication middleware
gem 'faraday', '~> 0.9.0'
gem 'faraday_middleware', '~> 0.10.0'

# JSON-API support: https://github.com/apotonick/roar/pull/98
gem 'roar', '~> 1.0.0'

# gem 'multi_json'
# gem 'oj'
gem 'json', '~> 2.3'
# gem "sinatra", require: "sinatra/base"
# gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
# gem "sinatra-router"
gem 'puma', '~> 3.9'

## Time & Space
gem 'ice_cube', '~> 0.16.0' # Date/Time helper

gem 'icalendar', '~> 2.3.0'

## Background tasks & Scheduling
gem 'rufus-scheduler', '~> 3.1', require: false

## Helper stuff
gem 'activesupport', '~> 4.2'
gem 'corefines', '~> 1.9'
gem 'role_playing', '~> 0.1.5'
gem 'logging', '~> 2.1'
gem 'oauth2', '~> 1.4'
gem 'celluloid', '~> 0.17.2'
gem 'rack-timeout', '~> 0.4'  # required by pliny

## For console
gem 'pry', require: false

## Error reporting
gem 'sentry-raven', '~> 1.0'
gem 'rollbar', '~> 2.11' # required by pliny

group :development do
  gem 'guard-shotgun', '~> 0.4.0', require: false
  gem 'guard-rspec', '~> 4.7', require: false
  gem 'foreman', '~> 0.84.0'

  gem 'kramdown', '~> 1.13', require: false
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'guard-yard', '~> 2.2', require: false
end

group :test do
  gem 'committee', '~> 1.15'
  gem 'rspec', '~> 3.3'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'rspec-http', '~> 0.11'
  gem 'rspec-parameterized', github: 'jnv/rspec-parameterized', branch: 'badbf07'
  gem 'rack-test', '~> 0.6.3'
  gem 'bogus', '~> 0.1.6'
  gem 'database_cleaner', '~> 1.6'
  gem 'timecop', '~> 0.8.1'
  gem 'codeclimate-test-reporter', '~> 1.0', require: nil
  gem 'coveralls', '~> 0.8.19', require: false
  gem 'fabrication', '~> 2.16'
  gem 'json_spec', '~> 1.1'
  gem 'vcr', '~> 3.0'
  gem 'rake-jekyll', '~> 1.1', require: false
  gem 'elasticsearch-extensions', '~> 0.0.26'
end

group :development, :test do
  gem 'pry-nav', '~> 0.2.4', require: false
  gem 'pry-byebug', '~> 3.4', require: false
  gem 'awesome_print', '~> 1.7'
end
