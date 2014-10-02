require 'bundler'
Bundler.setup
require 'clockwork'
require_relative 'lib/initializer'

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 60
    config[:thread] = true
    config[:max_threads] = 1
  end
  error_handler do |error|
    Raven.capture_exception(error,
                            tags: {
                              process: 'clock'
                            })
  end

  every(1.day, 'sync', at: ['00:30', '12:30']) do #|job|
    require 'sirius/schedule_manager'
    manager = Sirius::ScheduleManager.new
    manager.import_parallels
    manager.import_students
    manager.plan_stored_parallels
    puts "sync finished at #{Time.now}"
  end
end
