module Rubic
  module Builtin
    class List
      def cons(a, b)
        [a, b]
      end

      def car(l)
        unless pair? l
          raise Rubic::TypeError, "pair required, but got `#{l}'"
        end
        l.first
      end

      def cdr(l)
        unless pair? l
          raise Rubic::TypeError, "pair required, but got `#{l}'"
        end
        l.last
      end

      def list(*args)
        args.reverse.reduce([]) {|res, e| [e, res] }
      end

      def pair?(suspect)
        suspect.is_a?(Array) ? suspect.any? : false
      end

      def null?(suspect)
        suspect.is_a?(Array) ? suspect.empty? : false
      end
    end
  end
end
