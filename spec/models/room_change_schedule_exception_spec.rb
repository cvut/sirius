require 'spec_helper'
require 'room_change_schedule_exception'

describe RoomChangeScheduleException do

  subject(:exception) { described_class.new(options: Sequel.hstore(room_id: 'T9:155')) }
  let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 'T9:355') }

  describe '#apply' do
    it 'changes room_id' do
      expect { exception.apply(event) }.to change(event, :room_id).from('T9:355').to('T9:155')
    end
  end
end
