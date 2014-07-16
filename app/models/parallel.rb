class Parallel < Sequel::Model

  many_to_one :course
  one_to_many :timetable_slots

  DB_KEYS = [:id, :code, :capacity, :occupied, :semester, :teacher]

  def self.from_kosapi(kosapi_parallel)
    parallel_hash = kosapi_parallel.to_hash
    parallel_hash[:id] = parallel_hash[:link].href.split('/').last
    parallel_hash = parallel_hash.select { |key,_| DB_KEYS.include? key }

    Parallel.unrestrict_primary_key
    parallel = self.new(parallel_hash)
    parallel.save
    kosapi_parallel.timetable_slots.each do |slot|
      TimetableSlot.from_kosapi(slot, parallel_hash)
    end
    parallel
  end

  def generate_events(time_converter, calendar_planner)
    teaching_times = teaching_times(time_converter)
    event_periods = plan_calendar(teaching_times, calendar_planner)
    create_events(event_periods)
  end

  private
  def teaching_times(time_converter)
    timetable_slots.map do |slot|
      teaching_period = time_converter.convert_time(slot.first_hour, slot.duration)
      Sirius::TeachingTime.new(teaching_period: teaching_period, day: slot.day, parity: slot.parity)
    end
  end

  def plan_calendar(teaching_times, calendar_planner)
    teaching_times.map{ |tt| tt.plan_calendar(calendar_planner) }.flatten
  end

  def create_events(event_periods)
    factory = Sirius::EventFactory.new
    event_periods.map { |period| factory.build_event(period) }
  end

end
