DB = Sequel.connect(Config.database_url, max_connections: Config.db_pool)

Sequel::Model.plugin :timestamps, update_on_create: true
DB.extension :pg_hstore
DB.extension :pg_array
Sequel.extension :pg_array_ops
