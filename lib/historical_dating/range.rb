class HistoricalDating::Range
  def initialize(from, to)
    @from = from
    @to = to
  end

  attr_reader :from, :to

  def julian_range
    [from.jd, to.jd]
  end
end