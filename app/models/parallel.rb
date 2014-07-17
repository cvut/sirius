require 'models/person'
require 'models/course'
require 'models/timetable_slot'

class Parallel < Sequel::Model

  many_to_one :course
  one_to_many :timetable_slots

  class << self

    DB_KEYS = [:id, :code, :capacity, :occupied, :semester, :teacher]

    def from_kosapi(kosapi_parallel)
      parallel_hash = get_attr_hash(kosapi_parallel)
      teachers = load_teachers(kosapi_parallel)
      course = load_course(kosapi_parallel)
      parallel = create_parallel(parallel_hash, teachers, course)
      process_slots(kosapi_parallel)
      parallel
    end

    def get_attr_hash(kosapi_parallel)
      parallel_hash = kosapi_parallel.to_hash
      parallel_hash[:id] = parallel_hash[:link].id
      parallel_hash.select { |key,_| DB_KEYS.include? key }
    end

    def load_teachers(kosapi_parallel)
      Person.unrestrict_primary_key
      kosapi_parallel.teachers.map do |teacher_link|
        Person.find_or_create(id: teacher_link.id, full_name: teacher_link.title)
        teacher_link.id
      end
    end

    def load_course(kosapi_parallel)
      course = kosapi_parallel.course
      Course.unrestrict_primary_key
      Course.find_or_create(id: course.id, name: Sequel.hstore({en: course.title}) )
    end

    def create_parallel(attr_hash, teachers, course)
      Parallel.unrestrict_primary_key
      parallel = self.new(attr_hash)
      parallel.teacher_ids = teachers
      parallel.course = course
      parallel.save
    end

    def process_slots(kosapi_parallel)
      kosapi_parallel.timetable_slots.each do |slot|
        TimetableSlot.from_kosapi(slot, kosapi_parallel)
      end
    end
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
