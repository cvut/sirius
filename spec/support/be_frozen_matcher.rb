RSpec::Matchers.define :be_frozen do
  match do |actual|
    expect( actual.frozen? ).to be(true), 'expected frozen object'
  end
end
