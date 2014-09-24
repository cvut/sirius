# XXX: postgresql plugin passes the 'postgresql:' URL,
# while Sequel expects 'postgres' adapter
require 'sequel'
db_url = Config.database_url.sub(/\Apostgresql:/, 'postgres:')

DB = Sequel.connect(db_url, max_connections: Config.db_pool)

Sequel::Model.plugin :timestamps, update_on_create: true
DB.extension :pg_hstore
DB.extension :pg_array
Sequel.extension :pg_array_ops
