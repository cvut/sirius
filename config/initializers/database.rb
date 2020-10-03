require 'logging'
require 'sequel'
# Must be required before Sequel extensions are loaded.
require 'sequel/extensions/core_refinements'

# XXX: postgresql plugin passes the 'postgresql:' URL,
# while Sequel expects 'postgres' adapter
db_url = Config.database_url.sub(/\Apostgresql:/, 'postgres:')

DB = Sequel.connect(db_url, max_connections: Config.db_pool)

# Log level at which to log SQL queries.
DB.sql_log_level = :debug
DB.logger = Logging.logger[:sql]

# Do not output deprecation messages in production env.
Sequel::Deprecation.output = false if Config.rack_env == 'production'

# Allow to use notation :table__column and :table___alias.
Sequel.split_symbols = true

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :enum_guard
DB.extension :pg_hstore
DB.extension :pg_array
Sequel.extension :pg_array_ops
Sequel.extension :pg_hstore_ops
DB.extension :pg_enum
