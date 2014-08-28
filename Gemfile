source 'https://rubygems.org'
ruby '2.1.2'

gem 'rake'

# Storage
gem 'pg'
gem 'sequel'
gem 'sequel_pg', require: 'sequel'
gem 'kosapi_client', github: 'cvut/kosapi_client.rb'

# REST API
gem 'pliny', '~> 0.2.1'
gem 'grape'
gem 'roar', github: 'apotonick/roar'
# gem 'multi_json'
# gem 'oj'
gem 'json'
# gem "sinatra", require: "sinatra/base"
# gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
# gem "sinatra-router"
gem 'thin'

# Time & Space
gem 'ice_cube' # Date/Time helper
gem 'icalendar', '~> 2.1.0'

# Helper stuff
gem 'activesupport'
gem 'role_playing'

# For console
gem 'pry', require: false

group :development do
  gem 'guard-shotgun', github: 'jnv/guard-shotgun', require: false
  gem 'guard-rspec', require: false
  gem 'foreman'

  gem 'kramdown', require: false
  gem 'guard-livereload', require: false
  gem 'guard-yard', require: false
end

group :test do
  gem 'committee'
  gem 'rspec', '~> 3.0.0'
  gem 'rack-test'
  gem 'bogus'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'coveralls', require: false
  gem 'fabrication'
  gem 'json_spec', '~> 1.1.2'
  gem 'vcr'
end

group :development, :test do
  gem 'pry-nav', '~> 0.2.4', require: false
  gem 'pry-byebug', require: false
  gem 'awesome_print'
end


