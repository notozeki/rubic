module Rubic
  module Builtin
    class Number
      def +(*args)
        args.reduce(0) do |res, i|
          unless number? i
            raise Rubic::TypeError, "operation `+' is not defined between `#{res}' and `#{i}'"
          end
          res + i
        end
      end

      def -(*args)
        case args.size
        when 0
          raise Rubic::ArgumentError, "wrong number of arguments (0 for 1+)"
        when 1
          -args.first
        else
          args.reduce do |res, i|
            unless number? i
              raise Rubic::TypeError, "operation `-' is not defined between `#{res}' and `#{i}'"
            end
            res - i
          end
        end
      end

      def *(*args)
        args.reduce(1) do |res, i|
          unless number? i
            raise Rubic::TypeError, "operation `*' is not defined between `#{res}' and `#{i}'"
          end
          res * i
        end
      end

      def /(*args)
        case args.size
        when 0
          raise Rubic::ArgumentError, "wrong number of arguments (0 for 1+)"
        when 1
          1 / args.first
        else
          args.reduce do |res, i|
            unless number? i
              raise Rubic::TypeError, "operation `/' is not defined between `#{res}' and `#{i}'"
            end
            res / i
          end
        end
      end

      def <(a, b)
        unless number?(a) && number?(b)
          raise Rubic::TypeError, "operation `<' is not defined between `#{a}' and `#{b}'"
        end
        a < b
      end

      def >(a, b)
        unless number?(a) && number?(b)
          raise Rubic::TypeError, "operation `>' is not defined between `#{a}' and `#{b}'"
        end
        a > b
      end

      define_method '=' do |a, b|
        unless number?(a) && number?(b)
          raise Rubic::TypeError, "operation `=' is not defined between `#{a}' and `#{b}'"
        end
        a == b
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
    end
  end
end
