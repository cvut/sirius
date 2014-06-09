# Setup DB connection
require 'yaml'
require 'sequel'

db_config = YAML.load_file('config/database.yml')[RACK_ENV]
DB = Sequel.connect(db_config)
DB.extension :pg_hstore
