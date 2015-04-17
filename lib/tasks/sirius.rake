namespace :sirius do

  desc 'Fetches parallels and students from KOSapi and plans stored parallels'
  task :events => %w(events:import events:import_students events:plan events:assign_people events:import_exams events:import_exam_students events:import_course_events events:import_course_event_students)

  task :env do
    require 'bundler'
    Bundler.setup
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

    desc 'Assigns people from parallels to events.'
    task :assign_people => :env do
      puts 'Assigning people to events.'
      build_manager.assign_people
    end

    desc 'Imports exams from KOSapi and generates corresponding events.'
    task :import_exams => :env do
      puts 'Importing exams.'
      build_manager.import_exams
    end

    desc 'Import students for saved exam events for all active semesters.'
    task :import_exam_students => :env do
      puts 'Importing exam students.'
      build_manager.import_exam_students
    end

    desc 'Import course events for all active semesters.'
    task :import_course_events => :env do
      puts 'Importing course events.'
      build_manager.import_course_events
    end

    desc 'Import course event students for all active semesters.'
    task :import_course_event_students => :env do
      puts 'Importing course event students.'
      build_manager.import_course_event_students
    end
  end

end

def build_manager
  require 'sirius/schedule_manager'
  Sirius::ScheduleManager.new
end
