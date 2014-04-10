class Parallel < Sequel::Model

  many_to_one :course

  attr_accessor :timetable_slots

  def teaching_times(time_converter)
    @timetable_slots.map do |slot|
      teaching_period = time_converter.convert_time(slot.first_hour, slot.duration)
      Sirius::TeachingTime.new(teaching_period: teaching_period, day: slot.day, parity: slot.parity)
    end
  end

end
