require 'spec_helper'

RSpec::Matchers.define :parse do |input|
  match do |parser|
    begin
      parser.parse input
    rescue Parslet::ParseFailed
      false
    rescue Kor::Exception
      false
    end
  end
end

RSpec.describe HistoricalDating::Parser do
  it "should parse positive numbers including a zero" do
    expect(subject.positive_number).to parse("0")
    expect(subject.positive_number).to parse("1")
    expect(subject.positive_number).to parse("2134")
    expect(subject.positive_number).not_to parse("02134")
    expect(subject.positive_number).not_to parse("-2")
  end

  it "should parse whole numbers" do
    expect(subject.whole_number).to parse("0")
    expect(subject.whole_number).to parse("-10")
    expect(subject.whole_number).to parse("-1")

    expect(subject.whole_number).not_to parse("-0")
    expect(subject.whole_number).not_to parse("+0")
  end

  it "should parse correctly with it's utility parsers" do
    expect(subject.space).to parse(' ')
    expect(subject.space).to parse('  ')
    expect(subject.space).not_to parse('')

    expect(subject.christ).to parse('Christus')
    expect(subject.christ).to parse('Chr.')

    expect(subject.age_before).to parse('v.')
    expect(subject.age_before).to parse('vor')
  end

  it "should parse year numbers" do
    expect(subject.year).to parse('1982')
    expect(subject.year).to parse('2000 v. Chr.')
    expect(subject.year).to parse('1')
    expect(subject.year).to parse('7 vor Christus')
    expect(subject.year).to parse('0')
  end

  it "should parse century strings" do
    expect(subject.century).to parse('14. Jahrhundert')
    expect(subject.century).to parse('1. Jh. vor Christus')
    expect(subject.century).to parse('2. Jahrhundert nach Christus')
    expect(subject.century).not_to parse('-1. Jh. v. Chr.')
  end

  it "should parse days and months" do
    expect(subject.day).to parse('1')
    expect(subject.day).to parse('29')
    expect(subject.day).to parse('10')
    expect(subject.day).to parse('31')
    expect(subject.day).not_to parse('0')
    expect(subject.day).not_to parse('32')

    expect(subject.month).to parse("1")
    expect(subject.month).to parse("7")
    expect(subject.month).to parse("12")
    expect(subject.month).not_to parse("0")
  end

  it "should parse '1533'" do
    expect(subject.transform("1533")).to eql(
      from: Date.new(1533, 1, 1),
      to: Date.new(1533, 12, 31)
    )
  end

  it "should parse 'ca. 1400'" do
    expect(subject.transform("ca. 1400")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1405, 12, 31)
    )
  end

  it "should parse <century> bis <century>" do
    expect(subject.transform("12. Jh. bis 14. Jh.")).to eql(
      from: Date.new(1100, 1, 1),
      to: Date.new(1399, 12, 31)
    )
  end

  it "should parse single dates" do
    expect(subject.transform("20.6.1934")).to eql(
      from: Date.new(1934, 6, 20),
      to: Date.new(1934, 6, 20)
    )

    result = subject.transform("15.4.1982 bis 16.4.1983")
    expect(result).to eql(
      from: Date.new(1982, 4, 15),
      to: Date.new(1983, 4, 16)
    )
  end

  it "should parse 'ca. 1400 bis 1480'" do
    expect(subject.transform("ca. 1400 bis 1480")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1480, 12, 31)
    )
  end

  it "should parse 'ca. 1400 bis ca. 1480'" do
    expect(subject.transform("ca. 1400 bis ca. 1480")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1485, 12, 31)
    )
  end

  it "should parse '1400 bis ca. 1480'" do
    expect(subject.transform("1400 bis ca. 1480")).to eql(
      from: Date.new(1400, 1, 1),
      to: Date.new(1485, 12, 31)
    )
  end

  it "should parse '? bis 1456'" do
    expect(subject.transform("? bis 1456")).to eql(
      from: Date.new(1456 - (Date.today.year - 1456) / 10, 1, 1),
      to: Date.new(1456, 12, 31)
    )
  end

  it "should parse 'vor 1883'" do
    expect(subject.transform('vor 1883')).to eql(
      from: Date.new(1870, 1, 1),
      to: Date.new(1883, 12, 31)
    )
  end

  it "should parse 'nach 1883'" do
    expect(subject.transform('nach 1883')).to eql(
      from: Date.new(1883, 1, 1),
      to: Date.new(1896, 12, 31)
    )
  end

  it "should parse 'nicht vor 1883'" do
    expect(subject.transform('nicht vor 1883')).to eql(
      from: Date.new(1883, 1, 1),
      to: Date.new(1896, 12, 31)
    )
  end

  it "should parse 'nicht nach 1883'" do
    expect(subject.transform('nicht nach 1883')).to eql(
      from: Date.new(1870, 1, 1),
      to: Date.new(1883, 12, 31)
    )
  end

  it "should parse 'um 1555'" do
    expect(subject.transform('um 1555')).to eql(
      from: Date.new(1550, 1, 1),
      to: Date.new(1560, 12, 31)
    )
  end

  it "should parse 'circa 1555'" do
    expect(subject.transform('circa 1555')).to eql(
      from: Date.new(1550, 1, 1),
      to: Date.new(1560, 12, 31)
    )
  end

  it "should parse 'ca. 15. Jahrhundert'" do
    expect(subject.transform("ca. 15. Jahrhundert")).to eql(
      from: Date.new(1375, 1, 1),
      to: Date.new(1524, 12, 31)
    )
  end

  it "should parse '1877.11.02'" do
    expect(subject.transform('1877.11.02')).to eql(
      from: Date.new(1877, 11, 2),
      to: Date.new(1877, 11, 2)
    )
  end

  it "should parse '1877.01.23'" do
    expect(subject.transform('1877.01.23')).to eql(
      from: Date.new(1877, 1, 23),
      to: Date.new(1877, 1, 23)
    )
  end

  it "should parse '1877-01-23'" do
    expect(subject.transform('1877-01-23')).to eql(
      from: Date.new(1877, 1, 23),
      to: Date.new(1877, 1, 23)
    )
  end
  
  it "should parse explicit 'nach Christus'" do
    expect(subject.transform('1. Drittel 1. Jahrhundert nach Christus')).to eql(
      from: Date.new(0, 1, 1),
      to: Date.new(32, 12, 31)
    )
    expect(subject.transform('2. Jahrhundert nach Christus')).to eql(
      from: Date.new(100, 1, 1),
      to: Date.new(199, 12, 31)
    )
    expect(subject.transform('455 nach Christus')).to eql(
      from: Date.new(455, 1, 1),
      to: Date.new(455, 12, 31)
    )
    expect(subject.transform('ca. 312 nach Christus')).to eql(
      from: Date.new(307, 1, 1),
      to: Date.new(317, 12, 31)
    )
  end

  it "it should parse the old unit tests" do
    expect(subject.transform("1289")).to eql(from: Date.new(1289, 1, 1), to: Date.new(1289, 12, 31))
    expect(subject.transform("ca. 1289")).to eql(from: Date.new(1284, 1, 1), to: Date.new(1294, 12, 31))
    expect(subject.transform("ca. 1289 v. Chr.")).to eql(from: Date.new(-1294, 1, 1), to: Date.new(-1284, 12, 31))
    expect(subject.transform("16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("16. Jh. v. Chr.")).to eql(from: Date.new(-1599, 1, 1), to: Date.new(-1500, 12, 31))
    expect(subject.transform("Anfang 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1524, 12, 31))
    expect(subject.transform("Mitte 16. Jh.")).to eql(from: Date.new(1535, 1, 1), to: Date.new(1564, 12, 31))
    expect(subject.transform("Ende 16. Jh.")).to eql(from: Date.new(1575, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("1. Hälfte 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1549, 12, 31))
    expect(subject.transform("2. Hälfte 16. Jh.")).to eql(from: Date.new(1550, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("1. Drittel 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1532, 12, 31))
    expect(subject.transform("2. Drittel 16. Jh.")).to eql(from: Date.new(1533, 1, 1), to: Date.new(1565, 12, 31))
    expect(subject.transform("3. Drittel 16. Jh.")).to eql(from: Date.new(1566, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("1. Viertel 8. Jh. v. Chr.")).to eql(from: Date.new(-799, 1, 1), to: Date.new(-775, 12, 31))
    expect(subject.transform("2. Viertel 8. Jh. v. Chr.")).to eql(from: Date.new(-774, 1, 1), to: Date.new(-750, 12, 31))
    expect(subject.transform("3. Viertel 8. Jh. v. Chr.")).to eql(from: Date.new(-749, 1, 1), to: Date.new(-725, 12, 31))
    expect(subject.transform("4. Viertel 8. Jh. v. Chr.")).to eql(from: Date.new(-724, 1, 1), to: Date.new(-700, 12, 31))
  end

  it 'should deal with leap years' do
    expect(subject).to parse('29.2.1996')

    # parsing should work, but the transform should fail
    expect(subject).to parse('29.2.1994')

    expect do
      subject.transform('29.2.1994')
    end.to raise_error(HistoricalDating::Error){|e|
      expect(e.message).to eq('not_leap_year')
      expect(e.data[:year]).to eq(1994)
    }

    expect do
      expect(subject.transform('29.2.1994 bis 1.2.2013')).to eq(nil)
    end.to raise_error(HistoricalDating::Error){|e|
      expect(e.message).to eq('not_leap_year')
      expect(e.data[:year]).to eq(1994) 
    }
  end

  it "should parse 'vor 5. Jh. vor Chr.'" do
    expect(subject.transform("vor 5. Jh. v. Chr.")).to eql(from: Date.new(-599, 1, 1), to: Date.new(-500, 12, 31))
  end

  it "should parse '340 bis 320 v. Chr.'" do
    expect(subject.transform("340 bis 320 v. Chr.")).to eql(from: Date.new(-340, 1, 1), to: Date.new(-320, 12, 31))
  end

  it "should parse '1808/1812'" do
    expect(subject.transform("1808/1812")).to eql(from: Date.new(1808, 1, 1), to: Date.new(1812, 12, 31))
  end

  it "should parse '1230-1255'" do
    expect(subject.transform("1230-1255")).to eql(from: Date.new(1230, 1, 1), to: Date.new(1255, 12, 31))
  end

  it "should parse '1230 - 1255'" do
    expect(subject.transform("1230 - 1255")).to eql(from: Date.new(1230, 1, 1), to: Date.new(1255, 12, 31))
  end

  it "should parse '-480'" do
    expect(subject.transform("-480")).to eql(from: Date.new(-480, 1, 1), to: Date.new(-480, 12, 31))
  end

  # additional prometheus formats, see internal issue tracker at
  # https://redmine.prometheus-srv.uni-koeln.de/issues/392

  # it "should parse 'vor Mitte 5. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("vor Mitte 5. Jahrhundert v. Chr.")).to eql(from: Date.new(-549, 1, 1), to: Date.new(-450, 12, 31))
  # end

  # it "should parse 'zwischen 470 und 465 v. Chr.'" do
  #   expect(subject.transform("zwischen 470 und 465 v. Chr.")).to eql(from: Date.new(-470, 1, 1), to: Date.new(-465, 12, 31))
  # end

  # it "should parse 'Ende 1. Viertel 5. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("Ende 1. Viertel 5. Jahrhundert v. Chr.")).to eql(from: Date.new(-479, 1, 1), to: Date.new(-475, 12, 31))
  # end

  # it "should parse 'Ende 4. / Anfang 3. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("Ende 4. / Anfang 3. Jahrhundert v. Chr.")).to eql(from: Date.new(-324, 1, 1), to: Date.new(-275, 12, 31))
  # end

  # it "should parse 'Ende 7./1. Hälfte 6. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("Ende 7./1. Hälfte 6. Jahrhundert v. Chr.")).to eql(from: Date.new(-624, 1, 1), to: Date.new(-550, 12, 31))
  # end

  # it "should parse 'Ende 1. / 2. Viertel 4. Jahrhundert n. Chr.'" do
  #   expect(subject.transform("Ende 1. / 2. Viertel 4. Jahrhundert n. Chr.")).to eql(from: Date.new(320, 1, 1), to: Date.new(349, 12, 31))
  # end

  # it "should parse 'Wende 4./3. Jh. v. Chr.'" do
  #   expect(subject.transform("Wende 4./3. Jh. v. Chr.")).to eql(from: Date.new(-309, 1, 1), to: Date.new(-290, 12, 31))
  # end

  # it "should parse '2./3. Viertel 4. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("2./3. Viertel 4. Jahrhundert v. Chr.")).to eql(from: Date.new(-374, 1, 1), to: Date.new(-325, 12, 31))
  # end

  # it "should parse '4. Viertel 7. / 1. Viertel 6. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("4. Viertel 7. / 1. Viertel 6. Jahrhundert v. Chr.")).to eql(from: Date.new(-624, 1, 1), to: Date.new(-575, 12, 31))
  # end

  # it "should parse 'zweite Hälfte 8. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("zweite Hälfte 8. Jahrhundert v. Chr.")).to eql(from: Date.new(-749, 1, 1), to: Date.new(-700, 12, 31))
  # end

  # it "should parse '2. Hälfte 4. / 1. Hälfte 3. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("2. Hälfte 4. / 1. Hälfte 3. Jahrhundert v. Chr.")).to eql(from: Date.new(-349, 1, 1), to: Date.new(-250, 12, 31))
  # end

  # it "should parse '2. Hälfte 7./ Anfang 6. Jahrhundert v. Chr.'" do
  #   expect(subject.transform("2. Hälfte 7./ Anfang 6. Jahrhundert v. Chr.")).to eql(
  #     from: Date.new(-649, 1, 1), to: Date.new(-575, 12, 31)
  #   )
  # end

  it "should parse '430 - 420 v. Chr.'" do
    expect(subject.transform("430 - 420 v. Chr.")).to eql(
      from: Date.new(-430, 1, 1), to: Date.new(-420, 12, 31)
    )
  end

  # I need to keep the ConedaKOR case in mind here: The lib is used to validate
  # web input by users and while the semantics of this format make sense, it
  # seems like a typo that we would like to prevent. We could add a "lax" flag
  # to allow these cases. Or would you rather fix them in before handing it to
  # the parser? In any case, I added a test for the version without the typo
  # it "should parse '562/ 558 v. Chr.'" do
  #   expect(subject.transform("562/ 558 v. Chr.")).to eql(
  #     from: Date.new(-562, 1, 1), to: Date.new(-568, 12, 31)
  #   )
  # end

  it "should parse '562/558 v. Chr.'" do
    expect(subject.transform("562/558 v. Chr.")).to eql(
      from: Date.new(-562, 1, 1), to: Date.new(-558, 12, 31)
    )
  end

  it "should parse '26. - 23. Jahrhundert v. Chr.'" do
    expect(subject.transform("26. - 23. Jahrhundert v. Chr.")).to eql(
      from: Date.new(-2599, 1, 1), to: Date.new(-2200, 12, 31)
    )
  end

  it "should parse '1895/97'" do
    expect(subject.transform("1895/97")).to eql(
      from: Date.new(1895, 1, 1), to: Date.new(1897, 12, 31)
    )
  end

  it "should parse 'um 1829/30'" do
    expect(subject.transform("um 1829/30")).to eql(
      from: Date.new(1824, 1, 1), to: Date.new(1830, 12, 31)
    )
  end

  it "should parse '4000 - 3000 BC'" do
    expect(subject.transform("4000 - 3000 BC")).to eql(
      from: Date.new(-4000, 1, 1), to: Date.new(-3000, 12, 31)
    )
  end

  it "should parse '3100 BC'" do
    expect(subject.transform("3100 BC")).to eql(
      from: Date.new(-3100, 1, 1), to: Date.new(-3100, 12, 31)
    )
  end

  it "should parse 'um 3100 BC'" do
    expect(subject.transform("um 3100 BC")).to eql(
      from: Date.new(-3105, 1, 1), to: Date.new(-3095, 12, 31)
    )
  end

  it "should parse '2740 bis 2705 BC'" do
    expect(subject.transform("2740 bis 2705 BC")).to eql(
      from: Date.new(-2740, 1, 1), to: Date.new(-2705, 12, 31)
    )
  end

  it "should parse 'um 2445 - 2414 BC'" do
    expect(subject.transform("um 2445 - 2414 BC")).to eql(
      from: Date.new(-2450, 1, 1), to: Date.new(-2414, 12, 31)
    )
  end

  it "should parse 'nach 2221 BC'" do
    expect(subject.transform("nach 2221 BC")).to eql(
      from: Date.new(-2221, 1, 1), to: Date.new(-1797, 12, 31)
    )
  end

  it "should parse '150 - 60 v. Chr.'" do
    expect(subject.transform("150 - 60 v. Chr.")).to eql(
      from: Date.new(-150, 1, 1), to: Date.new(-60, 12, 31)
    )
  end

  it "should parse 'Ca. 530 v. Chr.'" do
    expect(subject.transform("Ca. 530 v. Chr.")).to eql(
      from: Date.new(-535, 1, 1), to: Date.new(-525, 12, 31)
    )
  end

  it "should parse 'Um 100 v. Chr.'" do
    expect(subject.transform("Um 100 v. Chr.")).to eql(
      from: Date.new(-105, 1, 1), to: Date.new(-95, 12, 31)
    )
  end

  it "should parse '40/ 50 n. Chr.'" do
    expect(subject.transform("40/ 50 n. Chr.")).to eql(
      from: Date.new(40, 1, 1), to: Date.new(50, 12, 31)
    )
  end

  it "should parse '100- 50 v. Chr.'" do
    expect(subject.transform("100- 50 v. Chr.")).to eql(
      from: Date.new(-100, 1, 1), to: Date.new(-50, 12, 31)
    )
  end

  it "should parse 'ab 1831'" do
    expect(subject.transform("ab 1831")).to eql(
      from: Date.new(1831, 1, 1), to: Date.new(1850, 12, 31)
    )
  end

  it "should parse '2. Jhd - 3. Jhd'" do
    expect(subject.transform("2. Jhd - 3. Jhd")).to eql(
      from: Date.new(100, 1, 1), to: Date.new(299, 12, 31)
    )
  end

  it "should parse '2. - 3. Jhd'" do
    expect(subject.transform("2. - 3. Jhd")).to eql(
      from: Date.new(100, 1, 1), to: Date.new(299, 12, 31)
    )
  end

  it "should parse '0 - 50'" do
    expect(subject.transform("0 - 50")).to eql(
      from: Date.new(0, 1, 1), to: Date.new(50, 12, 31)
    )
  end

  it "should parse '1. Jhd'" do
    expect(subject.transform("1. Jhd")).to eql(
      from: Date.new(0, 1, 1), to: Date.new(99, 12, 31)
    )
  end

  it "should parse '4. Jhd. BC'" do
    expect(subject.transform("4. Jhd. BC")).to eql(
      from: Date.new(-399, 1, 1), to: Date.new(-300, 12, 31)
    )
  end

  it "should parse '4. Jhd. - 3. Jhd BC'" do
    expect(subject.transform("4. Jhd. - 3. Jhd BC")).to eql(
      from: Date.new(-399, 1, 1), to: Date.new(-200, 12, 31)
    )
  end

  it "should parse '7. Jhd BC - 6. Jhd. BC'" do
    expect(subject.transform("7. Jhd BC - 6. Jhd. BC")).to eql(
      from: Date.new(-699, 1, 1), to: Date.new(-500, 12, 31)
    )
  end

  it "should parse '500 - 490 Bc'" do
    expect(subject.transform("500 - 490 Bc")).to eql(
      from: Date.new(-500, 1, 1), to: Date.new(-490, 12, 31)
    )
  end

  it "should parse '15 Jh'" do
    expect(subject.transform("15 Jh")).to eql(
      from: Date.new(1400, 1, 1), to: Date.new(1499, 12, 31)
    )
  end

  it "should parse '17. jh.'" do
    expect(subject.transform("17. jh.")).to eql(
      from: Date.new(1600, 1, 1), to: Date.new(1699, 12, 31)
    )
  end

  it "should parse '2 - 3 Jhd'" do
    expect(subject.transform("2 - 3 Jhd")).to eql(
      from: Date.new(100, 1, 1), to: Date.new(299, 12, 31)
    )
  end

  it "should parse 'von 1509 bis 1510'" do
    expect(subject.transform("von 1509 bis 1510")).to eql(
      from: Date.new(1509, 1, 1), to: Date.new(1510, 12, 31)
    )
  end

  it "should parse 'von 14. Jh bis 15. Jh.'" do
    expect(subject.transform("von 14. Jh bis 15. Jh.")).to eql(
      from: Date.new(1300, 1, 1), to: Date.new(1499, 12, 31)
    )
  end

  it "should parse 'zwischen 1534 - 1539'" do
    expect(subject.transform("zwischen 1534 - 1539")).to eql(
      from: Date.new(1534, 1, 1), to: Date.new(1539, 12, 31)
    )
  end

  it "should parse 'after 1979'" do
    expect(subject.transform("after 1979")).to eql(
      from: Date.new(1979, 1, 1), to: Date.new(1983, 12, 31)
    )
  end

  it "should parse '1985-02'" do
    skip 'Ambiguous date. "-" is used for year interval right now.'

    expect(subject.transform("1985-02")).to eql(
      from: Date.new(1985, 2, 1), to: Date.new(1985, 2, 28)
    )
  end

  it "should parse '1987-09'" do
    skip 'Ambiguous date. "-" is used for year interval right now.'

    expect(subject.transform("1987-09")).to eql(
      from: Date.new(1987, 9, 1), to: Date.new(1987, 9, 30)
    )
  end

  it "should parse '1987-12'" do
    skip 'Ambiguous date. "-" is used for year interval right now.'

    expect(subject.transform("1987-12")).to eql(
      from: Date.new(1987, 12, 1), to: Date.new(1987, 12, 31)
    )
  end

  it "should parse '10-06-1981'" do
    expect(subject.transform("10-06-1981")).to eql(
      from: Date.new(1981, 6, 10), to: Date.new(1981, 6, 10)
    )
  end

  it "should parse '06.1951'" do
    expect(subject.transform("06.1951")).to eql(
      from: Date.new(1951, 6, 1), to: Date.new(1951, 6, 30)
    )
  end

  it "should parse '1436 - 1449 AD'" do
    expect(subject.transform("1436 - 1449 AD")).to eql(
      from: Date.new(1436, 1, 1), to: Date.new(1449, 12, 31)
    )
  end

  it "should parse 'Zwischen 1450 und 1500'" do
    expect(subject.transform("Zwischen 1450 und 1500")).to eql(
      from: Date.new(1450, 1, 1), to: Date.new(1500, 12, 31)
    )
  end

  it "should parse '1700 - 1800'" do
    expect(subject.transform("1700 und 1800")).to eql(
      from: Date.new(1700, 1, 1), to: Date.new(1800, 12, 31)
    )
  end

  it "should parse '5/10/1862'" do
    expect(subject.transform("5/10/1862")).to eql(
      from: Date.new(1862, 10, 5), to: Date.new(1862, 10, 05)
    )
  end

  it "should parse '2.-3. Jh.'" do
    expect(subject.transform('2.-3. Jh.')).to eql(
      from: Date.new(100, 1, 1), to: Date.new(299, 12, 31)
    )
  end

  it "should parse '2.-3. Jh. n. Chr.'" do
    expect(subject.transform('2.-3. Jh. n. Chr.')).to eql(
      from: Date.new(100, 1, 1), to: Date.new(299, 12, 31)
    )
  end

  it "should parse '1885–1895'" do
    expect(subject.transform('1885–1895')).to eql(
      from: Date.new(1885, 1, 1), to: Date.new(1895, 12, 31)
    )
  end

  it "should parse '1959-60'" do
    expect(subject.transform('1959-60')).to eql(
      from: Date.new(1959, 1, 1), to: Date.new(1960, 12, 31)
    )
  end
end
