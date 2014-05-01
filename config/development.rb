DB.loggers = [Logger.new(STDOUT)]

# Load ALL THE FILES!!!
Dir["#{File.dirname(__FILE__)}/app/**/*.rb"].each { |f| load(f) }
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }
