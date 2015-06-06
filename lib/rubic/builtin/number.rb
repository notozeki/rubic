module Rubic
  module Builtin
    class Number
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
        case
        when integer?(suspect)
          true
        when rational?(suspect)
          true
        when real?(suspect)
          false
        when complex?(suspect)
          exact?(suspect.real) && exact?(suspect.imag)
        else
          false
        end
      end

      def inexact?(suspect)
        number?(suspect) && !exact?(suspect)
      end

      def zero?(suspect)
        unless number?(suspect)
          raise Rubic::TypeError, "`#{suspect}' is not a number"
        end
        suspect.zero?
      end

      def positive?(suspect)
        unless real?(suspect)
          raise Rubic::TypeError, "`#{suspect}' is not a real number"
        end
        suspect > 0.0
      end

      def negative?(suspect)
        unless real?(suspect)
          raise Rubic::TypeError, "`#{suspect}' is not a real number"
        end
        suspect < 0.0
      end

      def odd?(suspect)
        unless integer?(suspect)
          raise Rubic::TypeError, "`#{suspect}' is not an integer"
        end
        suspect.to_i.odd?
      end

      def even?(suspect)
        unless integer?(suspect)
          raise Rubic::TypeError, "`#{suspect}' is not an integer"
        end
        suspect.to_i.even?
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
    end
  end
end
