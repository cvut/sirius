require 'spec_helper'

describe Sirius::ScheduleTimeConverter do

  let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 }.values }
  subject(:converter) { Sirius::ScheduleTimeConverter.new(*schedule_params) }

  it 'calculates event start and end time' do

    result = converter.convert_time(1, 2)
    expect(result[:start_time]).to eq(Time.parse('7:30'))
    expect(result[:end_time]).to eq(Time.parse('9:00'))
  end
end