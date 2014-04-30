require 'yaml'
require 'logger'

namespace :db do
  task :environment do
    DATABASE_ENV = ENV['RACK_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  task :configuration => :environment do
    config_file = File.expand_path('../../../config/database.yml', __FILE__)
    @config = YAML.load_file(config_file)[DATABASE_ENV]
  end

  task :configure_connection => :configuration do
    require 'sequel'
    require 'sequel/extensions/migration'
    DB = Sequel.connect @config
    DB.loggers << Logger.new(STDOUT) if @config['logger']
  end

  desc 'Create the database from config/database.yml for the current DATABASE_ENV'
  task :create => :configure_connection do
    # create_database @config
  end

  desc 'Drops the database for the current DATABASE_ENV'
  task :drop => :configure_connection do
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :configure_connection do
    Sequel::Migrator.run(DB, MIGRATIONS_DIR)
  end

  namespace :schema do
    task :dump => :configure_connection do
      require 'sequel/extensions/schema_dumper'
      Sequel.extension :schema_dumper
      DB.extend Sequel::SchemaDumper
      File.open("db/schema.rb", "w") do |file|
        file << DB.dump_schema_migration(:same_db => true)
        # file << SequelRails::Migrations.dump_schema_information(:sql => false)
      end
      Rake::Task['db:schema:dump'].reenable
    end

    desc 'Load a schema.rb file into the database'
    task :load => :configure_connection do
      load('db/schema.rb')
    end
  end

  namespace :migrate do
    desc 'migrate to the specified version'
    task :to do
      desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
      task :rollback => :configure_connection do
        fail 'VERSION is required' unless version
        ::Sequel::Migrator.run(::Sequel::Model.db, MIGRATIONS_DIR, {version: version})
        # Rake::Task['db:dump'].invoke if SequelRails.configuration.schema_dump
      end
    end
  end

  namespace :enable do
    desc "enable hstore extension"
    task :hstore => :configure_connection do
      DB.run 'CREATE EXTENSION IF NOT EXISTS hstore;'
    end
  end

  # Rake::Task['db:schema:load'].enhance ['db:enable:hstore']
end

desc "create a Sequel migration in ./db/migrate"
  task :create_migration do
    name = ENV['NAME']
    abort("no NAME specified. use `rake db:create_migration NAME=create_users`") if !name

    migrations_dir = File.join("db", "migrate")
    version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")
    filename = "#{version}_#{name}.rb"
    # migration_name = name.gsub(/_(.)/) { $1.upcase }.gsub(/^(.)/) { $1.upcase }

    FileUtils.mkdir_p(migrations_dir)

    open(File.join(migrations_dir, filename), 'w') do |f|
      f << (<<-EOS).gsub("      ", "")
      Sequel.migration do
        change do

        end
      end
      EOS
    end
    puts "#{filename} created"
  end
