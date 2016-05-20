source 'https://rubygems.org'
unless ENV['CI']
  ruby '2.2.5'
end

gem 'rake'

## Storage
gem 'pg'
gem 'sequel', '~> 4.17'
gem 'sequel_pg', require: 'sequel'
gem 'kosapi_client', github: 'cvut/kosapi_client.rb'
gem 'chewy', '~> 0.8.2', '< 0.8.4'  # 0.8.4 is broken

## REST API
gem 'pliny', '~> 0.11.0'
gem 'dotenv'
gem 'grape', '~> 0.9.0'
gem 'warden', '~> 1.2.3' # authentication middleware
gem 'faraday', '~> 0.9.0'
gem 'faraday_middleware', '~> 0.10.0'

# JSON-API support: https://github.com/apotonick/roar/pull/98
gem 'roar', '~> 1.0.0'

# gem 'multi_json'
# gem 'oj'
gem 'json'
# gem "sinatra", require: "sinatra/base"
# gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
# gem "sinatra-router"
gem 'puma'

## Time & Space
gem 'ice_cube' # Date/Time helper

gem 'icalendar', '~> 2.3.0'

## Background tasks & Scheduling
gem 'rufus-scheduler', '~> 3.1', require: false

## Helper stuff
gem 'activesupport'
gem 'corefines', '~> 1.9'
gem 'role_playing', github: 'jnv/role_playing'
gem 'logging'
gem 'oauth2', github: 'cvut/oauth2', ref: 'd9f6fc3'

## For console
gem 'pry', require: false

## Error reporting
gem 'sentry-raven'

group :development do
  gem 'guard-shotgun', '~> 0.4.0', require: false
  gem 'guard-rspec', require: false
  gem 'foreman'

  gem 'kramdown', require: false
  gem 'guard-livereload', require: false
  gem 'guard-yard', require: false
end

group :test do
  gem 'committee'
  gem 'rspec', '~> 3.3'
  gem 'rspec-collection_matchers'
  gem 'rspec-http', '~> 0.11'
  gem 'rspec-parameterized', github: 'jnv/rspec-parameterized', branch: 'badbf07'
  gem 'rack-test'
  gem 'bogus'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'coveralls', require: false
  gem 'fabrication'
  gem 'json_spec', '~> 1.1'
  gem 'vcr'
  gem 'rake-jekyll', require: false
  gem 'elasticsearch-extensions'
end

group :development, :test do
  gem 'pry-nav', '~> 0.2.4', require: false
  gem 'pry-byebug', require: false
  gem 'awesome_print'
end
