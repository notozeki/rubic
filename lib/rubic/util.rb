module Rubic
  module Util
    def inexact_to_exact(num)
      case num
      when Complex
        r = inexact_to_exact(num.real)
        i = inexact_to_exact(num.imag)
        normalize_number Complex(r, i)
      when Float
        normalize_number num.rationalize
      when Rational, Integer
        num
      else
        raise TypeError, "unexpected type of number: #{num.class}"
      end
    end

    def exact_to_inexact(num)
      case num
      when Complex
        r = exact_to_inexact(num.real)
        i = exact_to_inexact(num.imag)
        normalize_number Complex(r, i)
      when Float, Rational, Integer
        num.to_f
      else
        raise TypeError, "unexpected type of number: #{num.class}"
      end
    end

    def normalize_number(num)
      case num
      when Complex
        num.imag.zero? ? num.real : num
      when Rational
        num.denominator == 1 ? num.numerator : num
      else
        num
      end
    end
  end
end
