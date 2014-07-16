require 'spec_helper'
require 'parity'

describe Parity do

  it 'has odd, even and both parity defined' do
    expect(Parity::BOTH).not_to be_nil
    expect(Parity::ODD).not_to be_nil
    expect(Parity::EVEN).not_to be_nil
  end

  it 'can be converted to numeric' do
    expect { Parity.to_numeric(Parity::BOTH) }.not_to raise_error
  end

  it 'can be converted from numeric' do
    expect { Parity.from_numeric(1) }.not_to raise_error
  end

  it 'keeps same value when already numeric' do
    expect( Parity.to_numeric(1) ).to eq 1
  end

end
