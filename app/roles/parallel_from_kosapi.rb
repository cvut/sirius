require 'role_playing'
require 'person'
require 'course'
require 'parallel'

class ParallelFromKOSapi < RolePlaying::Role

  class << self

    DB_KEYS = [:id, :code, :parallel_type, :capacity, :occupied]

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
      parallel_hash.select! { |key,_| DB_KEYS.include? key }
      parallel_hash[:id] = kosapi_parallel.link.link_id
      parallel_hash[:semester] = kosapi_parallel.semester.link_id
      parallel_hash
    end

    def load_teachers(kosapi_parallel)
      Person.unrestrict_primary_key
      kosapi_parallel.teachers.map do |teacher_link|
        Person.find_or_create(id: teacher_link.link_id, full_name: teacher_link.link_title)
        teacher_link.link_id
      end
    end

    def load_course(kosapi_parallel)
      course = kosapi_parallel.course
      Course.unrestrict_primary_key
      Course.find_or_create(id: course.link_id, name: Sequel.hstore({en: course.link_title}) )
    end

    def create_parallel(attr_hash, teachers, course)
      parallel = Parallel[attr_hash[:id]]
      Parallel.unrestrict_primary_key
      if parallel
        parallel.set(attr_hash)
      else
        parallel = Parallel.new(attr_hash)
      end
      parallel.teacher_ids = teachers
      parallel.course = course
      parallel.save
    end

    def process_slots(kosapi_parallel)
      kosapi_parallel.timetable_slots.each do |slot|
        TimetableSlotFromKOSapi.from_kosapi(slot, kosapi_parallel)
      end
    end

  end

end
