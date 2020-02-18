module HistoricalDating::Api
  def parser
    @parser ||= HistoricalDating::Parser.new
  end

  def parse(string, options = {})
    options = {
      locale: 'de'
    }.merge(options)

    unless options[:locale] == 'de'
      raise HistoricalDating::Error.new('locale_not_supported', locale: options[:locale])
    end

    result = parser.transform(string)
    HistoricalDating::Range.new(result[:from], result[:to])
  end
end