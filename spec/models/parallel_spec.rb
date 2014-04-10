require 'spec_helper'

describe Parallel do

  subject(:parallel) do
    par = Parallel.new
    par.timetable_slots = timetable_slots
    par
  end

  let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  let(:converter) { Sirius::ScheduleTimeConverter.new(schedule_params) }


  context 'when TimetableSlots are empty' do
    let(:timetable_slots) { [] }

    it 'outputs empty teaching times' do
      teaching_times = parallel.teaching_times(converter)
      expect(teaching_times).to eq([])
    end
  end

  context 'when TimetableSlots are filled in' do
    let(:timetable_slots) { [double('TimetableSlot', first_hour: 1, duration: 2, parity: :both, day: :monday)] }

    it 'converts Timetableslots to TeachingTimes' do
      teaching_times = parallel.teaching_times(converter)
      expect(teaching_times).to eq([Sirius::TeachingTime.new(teaching_period: Sirius::Period.parse('7:30', '9:00'), day: :monday, parity: :both)])
    end
  end



end
