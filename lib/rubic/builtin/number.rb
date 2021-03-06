require 'cmath'
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
          1.quo(args.first)
        else
          transitive_operation('/', args) {|a, b| a.quo(b) }
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

      def gcd(*args)
        exact = true
        ret = args.reduce(0) do |res, num|
          ensure_integer num
          exact &&= exact?(num)
          res.gcd(num.to_i)
        end
        exact ? ret : exact_to_inexact(ret)
      end

      def lcm(*args)
        exact = true
        ret = args.reduce(1) do |res, num|
          ensure_integer num
          exact &&= exact?(num)
          res.lcm(num.to_i)
        end
        exact ? ret : exact_to_inexact(ret)
      end

      def numerator(num)
        ensure_real num
        ret = num.to_r.numerator
        exact?(num) ? ret : exact_to_inexact(ret)
      end

      def denominator(num)
        ensure_real num
        ret = num.to_r.denominator
        exact?(num) ? ret : exact_to_inexact(ret)
      end

      def floor(num)
        ensure_real num
        num.floor
      end

      def ceiling(num)
        ensure_real num
        num.ceil
      end

      def truncate(num)
        ensure_real num
        num.truncate
      end

      def round(num)
        ensure_real num
        num.round
      end

      def rationalize(num, eps)
        ensure_real num
        normalize_number num.rationalize(eps)
      end

      def exp(num)
        ensure_number num
        CMath.exp(num)
      end

      def log(num)
        ensure_number num
        CMath.log(num)
      end

      def sin(num)
        ensure_number num
        CMath.sin(num)
      end

      def cos(num)
        ensure_number num
        CMath.cos(num)
      end

      def tan(num)
        ensure_number num
        CMath.tan(num)
      end

      def asin(num)
        ensure_number num
        CMath.asin(num)
      end

      def acos(num)
        ensure_number num
        CMath.acos(num)
      end

      def atan(*args)
        case args.size
        when 1
          ensure_number args[0]
          CMath.atan(args[0])
        when 2
          ensure_number args[0], args[1]
          Complex(args[1], args[0]).angle
        else
          raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
        end
      end

      def sqrt(num)
        ensure_number num
        CMath.sqrt(num)
      end

      def expt(x, y)
        ensure_number x, y
        x ** y
      end

      define_method 'make-rectangular' do |x, y|
        ensure_real x, y
        normalize_number Complex(x, y)
      end

      define_method 'make-polar' do |x, y|
        ensure_real x, y
        normalize_number Complex.polar(x, y)
      end

      define_method 'real-part' do |num|
        ensure_number num
        num.real
      end

      define_method 'imag-part' do |num|
        ensure_number num
        num.imag
      end

      def magnitude(num)
        ensure_number num
        num.magnitude
      end

      def angle(num)
        ensure_number num
        num.angle
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
