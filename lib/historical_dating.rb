require 'time'

require 'parslet'
require 'active_support/core_ext/integer/time'

require "historical_dating/version"

module HistoricalDating
  class Error < StandardError
    def initialize(message, data = {})
      super(message)
      @data = data
    end

    attr_reader :data
  end
  # Your code goes here...

  autoload :Api, 'historical_dating/api'
  autoload :Parser, 'historical_dating/parser'
  autoload :PreTransform, 'historical_dating/pre_transform'
  autoload :Range, 'historical_dating/range'
  autoload :Transform, 'historical_dating/transform'

  extend Api
end
