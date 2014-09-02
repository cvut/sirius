MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'.freeze
RACK_ENV = ENV['RACK_ENV'] || 'development'.freeze

# Logic for dumping database migrations to schema file
def available_migrations?
  File.exist?(MIGRATIONS_DIR) && Dir[File.join(MIGRATIONS_DIR, '*')].any?
end

def dump_schema_information(database_url:, sql: false)
  db = Sequel.connect(database_url)
  res = ''

  if available_migrations?
    migrator_class = ::Sequel::Migrator.send(:migrator_class, MIGRATIONS_DIR)
    migrator = migrator_class.new db, MIGRATIONS_DIR

    inserts = migrator.ds.map do |hash|
      insert = migrator.ds.insert_sql(hash)
      sql ? "#{insert};" : "    self << #{insert.inspect}"
    end

    if inserts.any?
      res << "Sequel.migration do\n  change do\n" unless sql
      res << inserts.join("\n")
      res << "\n  end\nend\n" unless sql
    end
  end
  res
end

namespace :db do
  Rake::Task['db:migrate'].enhance do
    if RACK_ENV == 'development'
      Rake::Task['db:schema:dump'].invoke
    end
  end

  # Append migration files to a generated schema file
  Rake::Task['db:schema:dump'].enhance do
    file = File.join('db', 'schema.sql')
    url = database_urls.first # XXX private method from pliny/tasks/db
    migrations = dump_schema_information(database_url: url, sql: true)
    File.open(file, 'r+') do |f|
      schema = f.read
      # redo comment stripping because it doesn't get flushed
      schema.gsub!(/^COMMENT ON EXTENSION.*\n/, '')
      schema << migrations
      f.rewind
      f.puts(schema)
    end
  end
end
