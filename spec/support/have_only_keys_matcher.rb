RSpec::Matchers.define :have_only_keys do |*expected|
  match do |actual|
    # use match_array to pass whole arguments array w/out expanding
    expect(actual.keys).to match_array(expected)
  end
end
