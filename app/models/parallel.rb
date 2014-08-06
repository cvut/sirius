require 'models/person'
require 'models/course'
require 'models/timetable_slot'
require 'sirius/event_factory'
require 'sirius/teaching_time'

class Parallel < Sequel::Model

  many_to_one :course
  one_to_many :timetable_slots

  def self.for_teacher(teacher_id)
    array_op = Sequel.pg_array(:teacher_ids)
    filter(array_op.contains([teacher_id]))
    # alternative: filter(teacher_id => array_op.any)
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
