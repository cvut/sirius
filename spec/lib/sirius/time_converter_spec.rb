require 'spec_helper'
require 'sirius/time_converter'

describe Sirius::TimeConverter do

  let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  subject(:converter) { Sirius::TimeConverter.new(schedule_params) }

  it 'calculates event start and end time' do
    result = converter.convert_time(1, 2)
    expect(result).to eq(Period.parse('7:30','9:00'))
  end

  it 'calculates start and end of odd hours' do
    result = converter.convert_time(12, 2)
    expect(result).to eq(Period.parse('17:00','18:30'))
  end

  it 'calculates start and end of odd duration' do
    result = converter.convert_time(13, 3)
    expect(result).to eq(Period.parse('18:00','20:15'))
  end

  it 'raises error with invalid start time' do
    expect { converter.convert_time(0, 2) }.to raise_error(RuntimeError)
  end

  it 'raises error with zero duration' do
    expect { converter.convert_time(5, 0) }.to raise_error(RuntimeError)
  end
end
