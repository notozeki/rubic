module Rubic
  class RubicError < StandardError; end
  class ArgumentError < RubicError; end
  class NameError < RubicError; end
  class ParseError < RubicError; end
end

require 'rubic/version'
require 'rubic/interpreter'
