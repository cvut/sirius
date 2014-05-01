require 'spec_helper'
require 'sirius/time_converter'

describe Sirius::TimeConverter do

  let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  subject(:converter) { Sirius::TimeConverter.new(schedule_params) }

  it 'calculates event start and end time' do

    result = converter.convert_time(1, 2)
    expect(result).to eq(Sirius::Period.parse('7:30','9:00'))
  end
end
