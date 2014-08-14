require 'spec_helper'
require 'models/room'

describe Room do

  subject(:room) { Room.create(kos_code: 'A-1442').reload }

  it 'has working timestamps' do
    expect(room.created_at).not_to be_nil
    expect(room.updated_at).to eq room.created_at
  end

  describe '.with_code!' do
    it 'fails for non-existent room' do
      expect { Room.with_code!('YOLO') }.to raise_error(Sequel::NoMatchingRow )
    end

    context 'with existing room' do
      before { room }
      it 'returns an existing room' do
        expect(Room.with_code! 'A-1442').to eql room
      end
    end
  end

  describe '#to_s' do
    subject(:room) { Room.new(kos_code: 'A-1442')}

    it "returns a room's KOS code" do
      expect(room.to_s).to eql 'A-1442'
    end
  end

end
