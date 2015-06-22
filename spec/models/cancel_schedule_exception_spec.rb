require 'spec_helper'
require 'cancel_schedule_exception'

describe CancelScheduleException do

  subject(:exception) { described_class.new() }
  let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 'T9:355') }

  describe '#apply' do
    it 'deletes an event' do
      expect { exception.apply(event) }.to change(event, :deleted).from(false).to(true)
    end
  end
end
