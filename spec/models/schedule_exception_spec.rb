require 'spec_helper'
require 'schedule_exception'

describe ScheduleException do

  describe '#apply' do

    let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 'T9:355') }
    subject(:exception) { Fabricate.build(:schedule_exception, id: 42, exception_type: 'room_change', options: Sequel.hstore(room_id: 'T9:155')) }
    let(:exception2) { Fabricate.build(:schedule_exception, id: 7, exception_type: 'room_change', options: Sequel.hstore(room_id: 'T9:105')) }

    it 'adds own id to event applied_schedule_exception_ids' do
      exception.apply(event)
      expect(event.applied_schedule_exception_ids).to contain_exactly(42)
    end

    it 'concatenates multiple schedule exception ids to event applied_schedule_exception_ids' do
      exception.apply(event)
      exception2.apply(event)
      expect(event.applied_schedule_exception_ids).to contain_exactly(42, 7)
    end
  end

  describe '#affects?' do

    describe 'time matching' do

      subject(:exception) { Fabricate.build(:schedule_exception, period: Period.parse('9:00', '11:00') ) }

      it 'returns true for an event in time range' do
        event = Fabricate.build(:event, period: Period.parse('9:00', '10:00'))
        expect( exception.affects?( event ) ).to be_truthy
      end

      it 'returns false for an event outside time range' do
        event = Fabricate.build(:event, period: Period.parse('14:00', '15:00'))
        expect( exception.affects?( event ) ).to be_falsey
      end

      it 'returns true for an event crossing time range' do
        event = Fabricate.build(:event, period: Period.parse('10:00', '12:00'))
        expect( exception.affects?( event ) ).to be_truthy
      end

    end

    describe 'timetable_slot matching' do

      subject(:exception) { Fabricate.build(:schedule_exception, timetable_slot_ids: [50, 123] ) }

      it 'matches with event from slot in exception' do
        event = Fabricate.build(:event, source_type: 'timetable_slot', source_id: 123)
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match with event from different slot' do
        event = Fabricate.build(:event, source_type: 'timetable_slot', source_id: 124)
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with empty timetable_slot_ids' do

        subject(:exception) { Fabricate.build(:schedule_exception, timetable_slot_ids: [] ) }

        it 'always matches' do
          event = Fabricate.build(:event, source_type: 'timetable_slot', source_id: 124)
          expect( exception.affects?(event) ).to be_truthy
        end
      end

    end

    describe 'course matching' do
      subject(:exception) { Fabricate.build(:schedule_exception, course_ids: %w(BI-CAO MI-PAR)) }

      it 'matches with event from specified course' do
        event = Fabricate.build(:event, course_id: 'MI-PAR')
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match with event from different course' do
        event = Fabricate.build(:event, course_id: 'MI-FOO')
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with empty course_ids' do
        subject(:exception) { Fabricate.build(:schedule_exception, course_ids: []) }

        it 'always matches' do
          event = Fabricate.build(:event, course_id: 124)
          expect( exception.affects?(event) ).to be_truthy
        end
      end
    end


    describe 'faculty matching' do
      subject(:exception) { Fabricate.build(:schedule_exception, faculty: 18000) }

      it 'matches with event from specified faculty' do
        event = Fabricate.build(:event, faculty: 18000)
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match with event from other faculty' do
        event = Fabricate.build(:event, faculty: 13000)
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with no faculty set' do
        subject(:exception) { Fabricate.build(:schedule_exception, faculty: nil) }

        it 'always matches' do
          event = Fabricate.build(:event, faculty: 13000)
          expect( exception.affects?(event) ).to be_truthy
        end
      end
    end

    describe 'semester matching' do
      subject(:exception) { Fabricate.build(:schedule_exception, semester: 'B141') }

      it 'matches an event with same semester' do
        event = Fabricate.build(:event, semester: 'B141')
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match an event with different semester' do
        event = Fabricate.build(:event, semester: 'B132')
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with no semester set' do
      subject(:exception) { Fabricate.build(:schedule_exception, semester: nil) }

        it 'always matches' do
          event = Fabricate.build(:event, semester: 'B132')
          expect( exception.affects?(event) ).to be_truthy
        end
      end
    end
  end
end
