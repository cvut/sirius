RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    expect(expected.strftime("%H:%M:%S%z").in_time_zone).to eq(actual.strftime("%H:%M:%S%z").in_time_zone)
  end
end
