class HistoricalDating::Transform < Parslet::Transform
  rule(:num => simple(:num), :part => simple(:part), :acbc => simple(:acbc), :cs => simple(:cs)) do
    modifier = case part
    when "Anfang" then [0, 75]
    when "Mitte" then [35, 35]
    when "Ende" then [75, 0]
    when "1. Hälfte" then [0, 50]
    when "2. Hälfte" then [50, 0]
    when "1. Drittel" then [0, 67]
    when "2. Drittel" then [33, 34]
    when "3. Drittel" then [66, 0]
    when "1. Viertel" then [0, 75]
    when "2. Viertel" then [25, 50]
    when "3. Viertel" then [50, 25]
    when "4. Viertel" then [75, 0]
    end

    if HistoricalDating::Transform.ac?(acbc)
      {
        :from => Date.new((num.to_i - 1) * 100 + modifier.first, 1, 1),
        :to => Date.new((num.to_i - 1) * 100 + 99 - modifier.last, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -100 + 1 + modifier.first, 1, 1),
        :to => Date.new((num.to_i - 1) * -100 - modifier.last, 12, 31)
      }
    end
  end

  rule(:num => simple(:num), :approx => simple(:approx), :acbc => simple(:acbc), :cs => simple(:cs)) do
    result = if HistoricalDating::Transform.ac?(acbc)
      {
        :from => Date.new((num.to_i - 1) * 100, 1, 1),
        :to => Date.new((num.to_i - 1) * 100 + 99, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -100 + 1, 1, 1),
        :to => Date.new((num.to_i - 1) * -100, 12, 31)
      }
    end

    if approx
      result[:from] -= 25.years
      result[:to] += 25.years
    end

    result
  end

  rule(:num => simple(:num), :approx => simple(:approx), :acbc => simple(:acbc)) do
    modifier = (approx ? 5 : 0)

    if HistoricalDating::Transform.ac?(acbc)
      {
        :from => Date.new(num.to_i - modifier, 1, 1),
        :to => Date.new(num.to_i + modifier, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -1 - modifier, 1, 1),
        :to => Date.new(num.to_i * -1 + modifier, 12, 31)
      }
    end
  end

  rule(:day => simple(:day), :month => simple(:month), :yearnum => simple(:yearnum)) do
    if !Date.leap?(yearnum.to_i) && month.to_i == 2 && day.to_i == 29
      raise HistoricalDating::Error.new('not_leap_year', year: yearnum.to_i)
    end

    {
      :from => Date.new(yearnum.to_i, month.to_i, day.to_i),
      :to => Date.new(yearnum.to_i, month.to_i, day.to_i),
    }
  end

  rule(:month => simple(:month), :yearnum => simple(:yearnum)) do
    {
      :from => Date.new(yearnum.to_i, month.to_i, 1),
      :to => Date.new(yearnum.to_i, month.to_i, -1),
    }
  end

  rule(:date => {:from => simple(:from), :to => simple(:to)}) do
    {:from => from, :to => to}
  end

  rule(:from => {:from => simple(:first_from), :to => simple(:first_to)}, :to => {:from => simple(:last_from), :to => simple(:last_to)}) do
    {:from => first_from, :to => last_to}
  end

  rule(before_century: {from: simple(:from), to: simple(:to) }) do
    {from: from - 100.years, to: to - 100.years}
  end

  [:century, :date_interval, :year, :year_interval, :interval, :century_interval, :century_part].each do |key|
    rule(key => {:from => simple(:from), :to => simple(:to)}) do
      if to < from
        raise HistoricalDating::Error, 'from_later_than_to'
      end

      {:from => from, :to => to}
    end
  end

  rule(:year_interval => subtree(:a)) do
    result = {}

    if a[:from] == '?'
      year = a[:to][:from].year
      result = HistoricalDating::Transform.open_start(year)
    else
      from = (a[:from].is_a?(Hash) ? a[:from][:from] : a[:from])
      result[:from] = Date.new(from.year, 1, 1)
      if a[:to] == '?'
        year = result[:from].year
        result = HistoricalDating::Transform.open_end(year)
      else
        result[:to] = Date.new(a[:to].year, 12, 31)
      end
    end

    result
  end

  rule(:before_year => subtree(:a)) do
    year = a[:date][:from].year
    if a[:not]
      HistoricalDating::Transform.open_end(year)
    else
      HistoricalDating::Transform.open_start(year)
    end
  end

  rule(:after_year => subtree(:a)) do
    year = a[:date][:from].year
    if a[:not]
      HistoricalDating::Transform.open_start(year)
    else
      HistoricalDating::Transform.open_end(year)
    end
  end

  def self.ac?(acbc)
    acbc.nil? || acbc.match(/(nach|n.) (Chr.|Christus)/) || acbc.match(/AC|Ac|Anno Domini|A. D.|AD/)
  end

  def self.open_start(year)
    return {
      from: Date.new(year - distance(year), 1, 1),
      to: Date.new(year, 12, 31)
    }
  end

  def self.open_end(year)
    return {
      from: Date.new(year, 1, 1),
      to: Date.new(year + distance(year), 12, 31)
    }
  end

  def self.distance(year)
    (today.year - year) / 10
  end

  def self.today
    Date.today
  end
end
