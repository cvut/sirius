require 'spec_helper'
require 'day'

describe Day do

  it 'converts day symbol to number' do
    expect(Day.to_numeric(Day::WEDNESDAY)).to eq 3
  end

  it 'converts number to day symbol' do
    expect(Day.from_numeric(3)).to eq Day::WEDNESDAY
  end

  it 'throws error when day symbol is invalid' do
    expect { Day.to_numeric(:foo) }.to raise_error(RuntimeError, /Invalid Day value/)
  end

  it 'throws error when day number is invalid' do
    expect { Day.from_numeric(42) }.to raise_error(RuntimeError, /Invalid Day number/)
  end

end
