require 'benchmark'

RACK_ENV = ENV['RACK_ENV'] || 'test'

namespace :benchmark do
  task :environment do
    DATABASE_ENV = ENV['RACK_ENV'] || 'test'
    require File.expand_path('../../config/boot', File.dirname(__FILE__))
    require 'sirius/schedule_manager'
    require 'database_cleaner'
    require 'vcr'

    VCR.configure do |c|
      c.cassette_library_dir = 'benchmark/cassettes'
      c.hook_into :faraday
      c.allow_http_connections_when_no_cassette = true
    end
  end

  desc 'Runs benchmark'
  task :run => :environment do
    manager = Sirius::ScheduleManager.new
    DatabaseCleaner[:sequel, {:connection => DB}]
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :truncation
    Benchmark.bm do |x|
      5.times do
        DatabaseCleaner.cleaning do
          VCR.use_cassette('kosapi_fetch_benchmark') do
            x.report('KOSapi') { manager.fetch_and_store_parallels(1000) }
          end
        end
      end
    end
  end
end
