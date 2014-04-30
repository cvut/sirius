require 'bogus/rspec'
require 'active_record'
require 'database_cleaner'
require 'shoulda-matchers'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Base.logger = Logger.new("log/test.log")

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    ActiveRecord::Migrator.migrate 'db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end

Bogus.configure do |c|
  c.fake_ar_attributes = true
end

# see: https://github.com/psyho/bogus/issues/35
# temporary until Bogus implements stub_const
def stub_const(name, value)
  previous_value = eval(name)
  Bogus.inject.overwrites_classes.overwrite(name, value)
  Bogus.inject.overwritten_classes.add(name, previous_value)
end

def load_path(path)
  File.join(File.dirname(__FILE__), path)
end

$LOAD_PATH << load_path("..")

