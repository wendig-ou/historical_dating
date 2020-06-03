require 'spec_helper'

describe HistoricalDating::Range do
  it 'should return time values' do
    result = HistoricalDating.parse('17. Jh.')
    range = described_class.new(result.from, result.to)
    expect(range.from_time).to eq(Time.mktime(1600, 1, 1))
    expect(range.to_time).to eq(Time.mktime(1699, 12, 31, 23, 59, 59))
  end
end
