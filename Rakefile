require 'pliny/tasks'
# Add your rake tasks to lib/tasks!
Dir['./lib/tasks/*.rake'].each do |task|
  load task rescue LoadError
end

task :default => :spec
