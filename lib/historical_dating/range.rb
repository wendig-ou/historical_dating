class HistoricalDating::Range
  def initialize(from, to)
    @from = from
    @to = to
  end

  attr_reader :from, :to

  def julian_range
    [from.jd, to.jd]
  end

  def from_time
    Time.mktime(from.year, from.month, from.day)
  end

  def to_time
    Time.mktime(to.year, to.month, to.day, 23, 59, 59)
  end
end
