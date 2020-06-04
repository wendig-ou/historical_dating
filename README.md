# HistoricalDating

Parse human historical datings and convert them to Julian day ranges. The
functionality was extracted from [ConedaKOR](https://github.com/coneda/kor).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'historical_dating'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install historical_dating

## Usage

~~~ruby
hd = HistoricalDating.parse("2. Jahrhundert nach Christus")
hd.from
# => #<Date: 0100-01-01 ((1757583j,0s,0n),+0s,2299161j)>
hd.to
# => #<Date: 0199-12-31 ((1794107j,0s,0n),+0s,2299161j)>
hd.julian_range
# => [1757583, 1794107]
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wendig-ou/historical_dating.
