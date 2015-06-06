require 'rubic/util'

module Rubic
  module Builtin
    class Number
      include Rubic::Util

      def +(*args)
        transitive_operation('+', 0, args) {|a, b| a + b }
      end

      def -(*args)
        case args.size
        when 0
          raise Rubic::ArgumentError, "wrong number of arguments (0 for 1+)"
        when 1
          -args.first
        else
          transitive_operation('-', args) {|a, b| a - b }
        end
      end

      def *(*args)
        transitive_operation('*', 1, args) {|a, b| a * b }
      end

      def /(*args)
        case args.size
        when 0
          raise Rubic::ArgumentError, "wrong number of arguments (0 for 1+)"
        when 1
          1 / args.first
        else
          transitive_operation('/', args) {|a, b| a / b }
        end
      end

      define_method '=' do |*args|
        if args.size < 2
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 2+)"
        else
          transitive_operation('=', args) do |a, b|
            (a == b) ? b : (return false)
          end
          true
        end
      end

      def >(*args)
        if args.size < 2
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 2+)"
        else
          transitive_operation('>', args) do |a, b|
            (a > b) ? b : (return false)
          end
          true
        end
      end

      def <(*args)
        if args.size < 2
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 2+)"
        else
          transitive_operation('<', args) do |a, b|
            (a < b) ? b : (return false)
          end
          true
        end
      end

      def >=(*args)
        if args.size < 2
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 2+)"
        else
          transitive_operation('>=', args) do |a, b|
            (a >= b) ? b : (return false)
          end
          true
        end
      end

      def <=(*args)
        if args.size < 2
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 2+)"
        else
          transitive_operation('<=', args) do |a, b|
            (a <= b) ? b : (return false)
          end
          true
        end
      end

      def number?(suspect)
        suspect.is_a?(Numeric) || complex?(suspect)
      end

      def complex?(suspect)
        suspect.is_a?(Complex) || real?(suspect)
      end

      def real?(suspect)
        suspect.is_a?(Float) || rational?(suspect)
      end

      def rational?(suspect)
        suspect.is_a?(Rational) || integer?(suspect)
      end

      def integer?(suspect)
        if suspect.is_a?(Float)
          suspect == suspect.truncate # X.0
        else
          suspect.is_a?(Integer)
        end
      end

      def exact?(suspect)
        case suspect
        when Complex
          exact?(suspect.real) && exact?(suspect.imag)
        when Float
          false
        when Rational
          true
        when Integer
          true
        else
          false
        end
      end

      def inexact?(suspect)
        number?(suspect) && !exact?(suspect)
      end

      def zero?(suspect)
        ensure_number suspect
        suspect.zero?
      end

      def positive?(suspect)
        ensure_real suspect
        suspect > 0.0
      end

      def negative?(suspect)
        ensure_real suspect
        suspect < 0.0
      end

      def odd?(suspect)
        ensure_integer suspect
        suspect.to_i.odd?
      end

      def even?(suspect)
        ensure_integer suspect
        suspect.to_i.even?
      end

      def max(a, *args)
        args.unshift(a)
        exact = args.all? do |e|
          ensure_real e
          exact?(e)
        end
        exact ? args.max : exact_to_inexact(args.max)
      end

      def min(a, *args)
        args.unshift(a)
        exact = args.all? do |e|
          ensure_real e
          exact?(e)
        end
        exact ? args.min : exact_to_inexact(args.min)
      end

      def abs(num)
        ensure_number num
        num.abs
      end

      def quotient(a, b)
        ensure_integer a, b
        ret = a.quo(b).round
        exact?(a) && exact?(b) ? ret : exact_to_inexact(ret)
      end

      def modulo(a, b)
        ensure_integer a, b
        ret = a.modulo(b)
        exact?(a) && exact?(b) ? ret : exact_to_inexact(ret)
      end

      def remainder(a, b)
        ensure_integer a, b
        ret = a.remainder(b)
        exact?(a) && exact?(b) ? ret : exact_to_inexact(ret)
      end

      define_method 'inexact->exact' do |num|
        ensure_number num
        return num if exact?(num)
        inexact_to_exact(num)
      end

      define_method 'exact->inexact' do |num|
        ensure_number num
        return num unless exact?(num)
        exact_to_inexact(num)
      end

      private

      def transitive_operation(opname, initial=nil, args)
        initial = args.shift if initial.nil?
        args.reduce(initial) do |res, num|
          unless number?(num)
            raise Rubic::TypeError, "operation `#{opname}' is not defined between `#{res}' and `#{num}'"
          end
          yield res, num
        end
      end

      def ensure_number(*args)
        args.each do |e|
          raise Rubic::TypeError, "`#{e}' is not a number" unless number?(e)
        end
      end

      def ensure_real(*args)
        args.each do |e|
          raise Rubic::TypeError, "`#{e}' is not a real number" unless real?(e)
        end
      end

      def ensure_integer(*args)
        args.each do |e|
          raise Rubic::TypeError, "`#{e}' is not an integer" unless integer?(e)
        end
      end

    end
  end
end
