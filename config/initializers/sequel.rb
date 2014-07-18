# Setup DB connection
require 'yaml'
require 'sequel'

db_config = YAML.load_file('config/database.yml')[RACK_ENV]
DB = Sequel.connect(db_config)

# Sequel extensions
Sequel::Model.plugin :timestamps, update_on_create: true
DB.extension :pg_array
Sequel.extension :pg_array_ops
DB.extension :pg_hstore

# Add ActiveModel compatibility
# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/ActiveModel.html
# Sequel::Model.plugin :active_model
