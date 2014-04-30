require "rspec/core/rake_task"


namespace :spec do

  task :prepare_env do
    ENV['RACK_ENV'] = 'test'
  end
end

RSpec::Core::RakeTask.new(:spec)

Rake::Task[:spec].enhance ['spec:prepare_env']
