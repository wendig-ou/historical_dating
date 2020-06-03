require 'spec_helper'

RSpec.describe HistoricalDating do
  it 'should fail when an unsupported locale is passed' do
    expect{
      described_class.parse('something', locale: 'en')
    }.to raise_error(HistoricalDating::Error){ |e|
      expect(e.message).to eq('locale_not_supported')
      expect(e.data[:locale]).to eq('en')
    }
  end

  it 'should return gregorian dates' do
    result = described_class.parse('17. Jh.')
    expect(result.from).to eq(Date.new(1600, 1, 1))
    expect(result.to).to eq(Date.new(1699, 12, 31))
  end

  it 'should return julian day ranges' do
    result = described_class.parse('17. Jh.')
    expect(result.julian_range).to eq([
      Date.new(1600, 1, 1).jd,
      Date.new(1699, 12, 31).jd
    ])
  end
end
