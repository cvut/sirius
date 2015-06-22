require 'spec_helper'
require 'room_change_schedule_exception'

describe RoomChangeScheduleException do

  subject(:exception) { described_class.new(options: Sequel.hstore(room_id: 'T9:155')) }
  let(:event) { Fabricate.build(:event, period: Period.parse('7:30', '9:00'), room_id: 'T9:355') }

  describe '#apply' do
    it 'changes room_id' do
      expect { exception.apply(event) }.to change(event, :room_id).from('T9:355').to('T9:155')
    end

    it 'sets original_room_id if not set' do
      expect { exception.apply(event) }.to change(event, :original_room_id).from(nil).to('T9:355')
    end

    context 'with original_room_id already set' do
      before { event.original_room_id = 'B1:123' }

      it 'does not change original_room_id' do
        expect { exception.apply(event) }.not_to change(event, :original_room_id).from('B1:123')
      end
    end
  end
end
