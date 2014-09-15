require 'spec_helper'
require 'roles/applied_schedule_exception'

describe AppliedScheduleException do

  subject(:exception) { described_class.new(wrapped_exception) }

  describe '#apply' do

    let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 11) }

    context 'with CANCEL exception' do

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, exception_type: Sirius::ScheduleExceptionType::CANCEL) }

      it 'deletes an event' do
        expect { exception.apply(event) }.to change(event, :deleted).from(false).to(true)
      end

    end

    context 'with RELATIVE_MOVE exception' do

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, exception_type: Sirius::ScheduleExceptionType::RELATIVE_MOVE, options: Sequel.hstore(offset: 15)) }

      it 'moves an event by a positive offset' do
        expect { exception.apply(event) }.to change(event, :period).from(Period.parse('7:30', '9:00')).to(Period.parse('7:45', '9:15'))
      end

    end

    context 'with ROOM_CHANGE exception' do

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, exception_type: Sirius::ScheduleExceptionType::ROOM_CHANGE, options: Sequel.hstore(room_id: 42)) }

      it 'changes room_id' do
        expect { exception.apply(event) }.to change(event, :room_id).from(11).to(42)
      end

    end

    context 'with invalid exception type' do

      let(:wrapped_exception) { double(exception_type: 'foo') }

      it 'raises error' do
        expect { exception.apply(event) }.to raise_error(RuntimeError)
      end
    end

  end

  describe '#affects?' do

    describe 'time matching' do

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, period: Period.parse('9:00', '11:00') ) }

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

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, timetable_slot_ids: [50, 123] ) }

      it 'matches with event from slot in exception' do
        event = Fabricate.build(:event, timetable_slot_id: 123)
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match with event from different slot' do
        event = Fabricate.build(:event, timetable_slot_id: 124)
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with empty timetable_slot_ids' do

        let(:wrapped_exception) { Fabricate.build(:schedule_exception, timetable_slot_ids: [] ) }

        it 'always matches' do
          event = Fabricate.build(:event, timetable_slot_id: 124)
          expect( exception.affects?(event) ).to be_truthy
        end
      end

    end

    describe 'course matching' do
      let(:wrapped_exception) { Fabricate.build(:schedule_exception, course_ids: %w(BI-CAO MI-PAR)) }

      it 'matches with event from specified course' do
        event = Fabricate.build(:event, course_id: 'MI-PAR')
        expect( exception.affects?(event) ).to be_truthy
      end

      it 'does not match with event from different course' do
        event = Fabricate.build(:event, course_id: 'MI-FOO')
        expect( exception.affects?(event) ).to be_falsey
      end

      context 'with empty course_ids' do
        let(:wrapped_exception) { Fabricate.build(:schedule_exception, course_ids: []) }

        it 'always matches' do
          event = Fabricate.build(:event, course_id: 124)
          expect( exception.affects?(event) ).to be_truthy
        end
      end
    end

  end

end
