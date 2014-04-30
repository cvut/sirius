require 'spec_helper'

describe Sirius::Semester do

  subject(:semester) { Sirius::Semester.new }
  let(:parallels) { [instance_double(Parallel, generate_events: [Event.new])] }

  it 'plans parallels' do
    events = semester.plan_parallels(parallels)
    expect(events).to eq [Event.new]
  end
end