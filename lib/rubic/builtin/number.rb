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
        suspect.is_a?(Integer) || suspect.is_a?(Float)
      end
    end
  end
end
