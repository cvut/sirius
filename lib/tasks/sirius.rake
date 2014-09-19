namespace :sirius do

  desc 'Fetches parallels and students from KOSapi and plans stored parallels'
  task :events => %w(events:import events:import_students events:plan)

  task :env do
    require 'bundler'
    Bundler.require
    require File.expand_path('../../lib/initializer', File.dirname(__FILE__))
  end

  namespace :events do

    desc 'Fetches parallels from KOSapi'
    task :import => :env do
      puts 'Importing parallels.'
      build_manager.import_parallels
    end

    desc 'Fetches students from KOSapi'
    task :import_students => :env do
      puts 'Importing students, grab a coffee.'
      build_manager.import_students
    end

    desc 'Plans stored parallels'
    task :plan => :env do
      puts 'Planning parallels.'
      build_manager.plan_stored_parallels
    end

  end

end

def build_manager
  require 'sirius/schedule_manager'
  Sirius::ScheduleManager.new
end
