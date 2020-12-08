class HistoricalDating::Parser < Parslet::Parser
  # Numbers

  rule(:zero){ str '0' }
  rule(:natural_number){ match['1-9'] >> match['0-9'].repeat }
  rule(:two_digit_natural_number){ match['1-9'] >> match['0-9'].repeat(0,1) }
  rule(:more_than_two_digit_natural_number){ match['1-9'] >> match['0-9'].repeat(2,nil) }
  rule(:positive_number){ zero | natural_number }
  rule(:two_digit_positive_number){ zero | two_digit_natural_number }
  rule(:more_than_two_digit_positive_number){ zero | more_than_two_digit_natural_number }
  rule(:minus){ match '-' }
  rule(:whole_number_without_zero){ natural_number | minus >> natural_number }
  rule(:whole_number_with_zero){ positive_number | minus >> natural_number }
  rule(:two_digit_whole_number_with_zero){ two_digit_positive_number | minus >> two_digit_natural_number }
  rule(:more_than_two_digit_whole_number_with_zero){ more_than_two_digit_positive_number | minus >> more_than_two_digit_natural_number }
  rule(:whole_number){ positive_number | minus >> natural_number }

  # Utility

  rule(:space){ str(' ').repeat(1, nil) }
  rule(:prefix){ (str('von') | str('zwischen') | str('Zwischen')) >> space }
  rule(:christ){ str('Chr.') | str('Christus') }
  rule(:age_before){ str('v.') | str('vor') }
  rule(:age_after){ str('n.') | str('nach') }
  rule(:ac){
    age_after >> space >> christ |
    str('AC') |
    str('Ac') |
    str('Anno Domini') |
    str('A. D.') |
    str('AD')
  }
  rule(:bc){
    age_before >> space >> christ |
    str('BC') |
    str('Bc')
  }
  rule(:acbc){
    ac | bc
  }
  rule(:century_string){
    str('Jahrhundert') |
    str('Jhd.') |
    str('jhd.') |
    str('Jhd') |
    str('jhd') |
    str('Jh.') |
    str('jh.') |
    str('Jh') |
    str('jh')
  }
  rule(:approx){ str('ca.') | str('Ca.') | str('ca') | str('um') | str('Um') | str('circa') }
  rule(:unknown){ str('?') | str('unbekannt') | str('onbekend') }
  rule(:to_characters){
    str('bis') | str('-') | str('/') | str('und')
  }
  rule(:to_two_digit_year){
    (space >> to_characters >> space) |
    (to_characters >> space) |
    (space >> to_characters) |
    str('/')
  }
  rule(:to){
    to_two_digit_year | str('-')
  }
  rule(:before){ (str('vor') | str('Vor') | str('before')) >> space }
  rule(:after){ (str('Nach') | str('nach') | str('ab') | str('after')) >> space }
  rule(:negate){ str('nicht') >> space }
  rule(:part){
    str('Anfang') |
    str('Mitte') |
    str('Ende') |
    str('1. Hälfte') |
    str('2. Hälfte') |
    str('1. Drittel') |
    str('2. Drittel') |
    str('3. Drittel') |
    str('1. Viertel') |
    str('2. Viertel') |
    str('3. Viertel') |
    str('4. Viertel')
  }

  # Dating

  rule(:day){ match['1-2'] >> match['0-9'] | str('3') >> match['0-1'] | match['1-9'] | str('0') >> match['1-9'] }
  rule(:month){ (str('0') >> match['1-9']) | (str('1') >> match['0-2']) | match['1-9'] }
  rule(:two_digit_year){ (approx >> space).maybe.as(:approx) >> two_digit_whole_number_with_zero.as(:num) >> (space >> acbc).maybe.as(:acbc) }
  rule(:more_than_two_digit_year){ (approx >> space).maybe.as(:approx) >> more_than_two_digit_whole_number_with_zero.as(:num) >> (space >> acbc).maybe.as(:acbc) }
  rule(:year){ (approx >> space).maybe.as(:approx) >> whole_number_with_zero.as(:num) >> (space >> acbc).maybe.as(:acbc) }
  rule(:century){
    (approx >> space).maybe.as(:approx) >>
    natural_number.as(:num) >>
    ((str('.').as(:cd) >> (space >> century_string.as(:cs) >> (space >> acbc).maybe.as(:acbc)).maybe) |
    (space >> century_string.as(:cs) >> (space >> acbc).maybe.as(:acbc)))
  }
  rule(:century_number){
    (approx >> space).maybe.as(:approx) >>
    natural_number.as(:num) >>
    (space >> century_string).maybe.as(:cs) >>
    (space >> acbc).maybe.as(:acbc)
  }
  rule(:century_part){ part.as(:part) >> space >> positive_number.as(:num) >> str('.') >> space >> century_string.as(:cs) >> (space >> acbc).maybe.as(:acbc) }
  rule(:european_date){
    (day.as(:day) >> (str('.') | str('-')) >>
    month.as(:month) >>
    (str('.') | str('-')) >>
    whole_number.as(:yearnum)) |
    (month.as(:month) >>
    (str('.') | str('-')) >>
    whole_number.as(:yearnum))
  }
  rule(:machine_date){ whole_number.as(:yearnum) >> (str('.') | str('-')) >> month.as(:month) >> ((str('.') | str('-')) >> day.as(:day)).maybe }
  rule(:date){ european_date | machine_date }
  rule(:date_interval){ date.as(:from) >> to >> date.as(:to) }
  rule(:century_interval){
    prefix.maybe >>
    (century.as(:from) | century_number.as(:from)) >>
    to >>
    century.as(:to)
  }
  rule(:before_year){ negate.maybe.as(:not) >> before >> year.as(:date) }
  rule(:after_year){ negate.maybe.as(:not) >> after >> year.as(:date) }
  rule(:year_interval){
    prefix.maybe >>
    (year | unknown).as(:from) >>
    ((to >>
    (more_than_two_digit_year | unknown).as(:to)) |
    (to_two_digit_year >>
    two_digit_year.as(:to)))
  }
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
