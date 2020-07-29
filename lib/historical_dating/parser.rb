class HistoricalDating::Parser < Parslet::Parser
  # Numbers

  rule(:zero){ str '0' }
  rule(:natural_number){ match['1-9'] >> match['0-9'].repeat }
  rule(:positive_number){ zero | natural_number }
  rule(:minus){ match '-' }
  rule(:whole_number_without_zero){ natural_number | minus >> natural_number }
  rule(:whole_number){ positive_number | minus >> natural_number }
  rule(:day){ match['1-2'] >> match['0-9'] | str('3') >> match['0-1'] | match['1-9'] | str('0') >> match['1-9'] }
  rule(:month){ str('1') >> match['0-2'] | match['1-9'] | str('0') >> match['1-9'] }

  # Utility

  rule(:space){ str(' ').repeat(1, nil) }
  rule(:christ){ str('Chr.') | str('Christus') }
  rule(:age){ str('v.') | str('vor') | str('n.') | str('nach') }
  rule(:acbc){ age >> space >> christ }
  rule(:century_string){ str('Jahrhundert') | str('Jh.') }
  rule(:approx){ str('ca.') | str('um') | str('circa') }
  rule(:unknown){ str('?') }
  rule(:to){ ((space >> (str('bis') | str('-') | str('/')) >> space) | str('-') | str('/')) }
  rule(:before){ str('vor') >> space }
  rule(:after){ str('nach') >> space }
  rule(:negate){ str('nicht') >> space }
  rule(:part){ str('Anfang') | str('Mitte') | str('Ende') | str('1. Hälfte') | str('2. Hälfte') | str('1. Drittel') | str('2. Drittel') | str('3. Drittel') | str('1. Viertel') | str('2. Viertel') | str('3. Viertel') | str('4. Viertel') }

  # Dating

  rule(:century){ (approx >> space).maybe.as(:approx) >> positive_number.as(:num) >> str('.') >> space >> century_string.as(:cs) >> (space >> acbc).maybe.as(:acbc) }
  rule(:year){ (approx >> space).maybe.as(:approx) >> whole_number_without_zero.as(:num) >> (space >> acbc).maybe.as(:acbc) }
  rule(:century_part){ part.as(:part) >> space >> positive_number.as(:num) >> str('.') >> space >> century_string.as(:cs) >> (space >> acbc).maybe.as(:acbc) }
  rule(:european_date){ day.as(:day) >> str('.') >> month.as(:month) >> str('.') >> whole_number.as(:yearnum) }
  rule(:machine_date){ whole_number.as(:yearnum) >> (str('.') | str('-')) >> month.as(:month) >> (str('.') | str('-')) >> day.as(:day) }
  rule(:date){ european_date | machine_date }
  rule(:date_interval){ date.as(:from) >> to >> date.as(:to) }
  rule(:century_interval){ century.as(:from) >> to >> century.as(:to) }
  rule(:before_year){ negate.maybe.as(:not) >> before >> year.as(:date) }
  rule(:after_year){ negate.maybe.as(:not) >> after >> year.as(:date) }
  rule(:year_interval){ year.as(:from) >> to >> (year | unknown).as(:to) | (year | unknown).as(:from) >> to >> year.as(:to) }
  rule(:before_century){ before >> century.as(:century) }
  rule(:interval){
    before_year.as(:before_year) |
      after_year.as(:after_year) |
      date_interval.as(:date_interval) |
      century_interval.as(:century_interval) |
      year_interval.as(:year_interval) |
      before_century.as(:before_century)
  }
  rule(:dating){
    interval.as(:interval) |
      century_part.as(:century_part) |
      century.as(:century) |
      date.as(:date) |
      year.as(:year)
  }

  root(:dating)

  # Transform

  def transform(input)
    result = self.class.new.parse(input)
    result = HistoricalDating::PreTransform.new.apply(result)
    HistoricalDating::Transform.new.apply(result)
  end
end
