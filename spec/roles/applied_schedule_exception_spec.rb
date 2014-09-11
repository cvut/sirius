require 'spec_helper'
require 'roles/applied_schedule_exception'

describe AppliedScheduleException do

  subject(:exception) { described_class.new(wrapped_exception) }

  describe '#apply' do

    let(:event) { Fabricate.build(:event) }

    context 'with CANCEL exception type' do

      let(:wrapped_exception) { Fabricate.build(:schedule_exception, exception_type: Sirius::ScheduleExceptionType::CANCEL) }

      it 'deletes an event' do
        expect { exception.apply(event) }.to change(event, :deleted).from(false).to(true)
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

end
