require 'sirius/semester'
require 'models/parallel'
require 'roles/parallel_from_kosapi'
require 'roles/planned_timetable_slot'

module Sirius
  class ScheduleManager

    DEFAULT_TIME_CONVERTER = TimeConverter.new(first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2)
    DEFAULT_CALENDAR_PLANNER = EventPlanner.new(teaching_period: Period.parse('22.9.2014','19.12.2014'), first_week_parity: :even)

    def initialize(client: KOSapiClient.client, time_converter: DEFAULT_TIME_CONVERTER, calendar_planner: DEFAULT_CALENDAR_PLANNER)
      @client = client
      @time_converter = time_converter
      @calendar_planner = calendar_planner
    end

    def plan_stored_parallels
      TimetableSlot.each do |sl|
        PlannedTimetableSlot.new(sl, @time_converter, @calendar_planner).tap do |slot|
          events = slot.generate_events
          events.each(&:save)
        end
      end
    end

    def fetch_and_store_parallels(parallels_limit = 20)
      total_parallels = 0
      parallels = fetch_parallels(0, 20, 'B132')
      DB.transaction do
        parallels.take_while do |parallel|
          ParallelFromKOSapi.from_kosapi(parallel)
          total_parallels += 1
          total_parallels < parallels_limit
        end
      end
    end


    private
    def load_semesters
      [Semester.new]
    end

    def fetch_parallels(offset, limit, semester, faculty = 18000)
      @client.parallels.where('course.faculty' => faculty, semester: semester).offset(offset).limit(limit)
    end

  end
end
