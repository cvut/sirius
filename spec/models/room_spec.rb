require 'spec_helper'
require 'models/room'

describe Room do

  it 'has working timestamps' do
    room = Room.new(kos_code: 'A-1442')
    room.save
    expect(room.created_at).not_to be_nil
    expect(room.updated_at).to eq room.created_at
  end

end
