require 'spec_helper'
require 'relative_move_schedule_exception'

describe RelativeMoveScheduleException do

  subject(:exception) { described_class.new(options: Sequel.hstore(offset: 15)) }
  let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 'T9:355') }

  describe '#apply' do
    it 'moves an event by a positive offset' do
      expect { exception.apply(event) }.to change(event, :period).from(Period.parse('7:30', '9:00')).to(Period.parse('7:45', '9:15'))
    end
  end
end
