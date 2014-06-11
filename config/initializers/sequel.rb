# Setup DB connection
require 'yaml'
require 'sequel'

db_config = YAML.load_file('config/database.yml')[RACK_ENV]
DB = Sequel.connect(db_config)
DB.extension :pg_hstore

# Add ActiveModel compatibility
# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/ActiveModel.html
# Used by ActiveModel Serializers, pagination
Sequel::Model.plugin :active_model
