require 'spec_helper'
require 'models/event'

describe Event do

  subject(:event) { Event.new(starts_at: Time.parse('11:00'), ends_at: Time.parse('12:30')) }
  let(:period) { Sirius::Period.parse('7:30', '9:00') }

  it 'returns correct calculated period' do
    expect(event.period).to eq Sirius::Period.parse('11:00', '12:30')
  end

  it 'sets starts_at and ends_at attributes from period=' do
    event.period = period
    expect(event.starts_at).to eq period.starts_at
    expect(event.ends_at).to eq period.ends_at
  end

end
