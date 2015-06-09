require 'minitest_helper'
require 'rubic'

class TestNumber < MiniTest::Test
  def setup
    @rubic = Rubic::Interpreter.new
  end

  def test_arithmetic_operations
    # Practical expressions are covered in
    # TestInterpreter#test_evaluate_expressions, so test edge cases in here.
    assert_equal 0, @rubic.evaluate('(+)')
    assert_equal 10, @rubic.evaluate('(+ 10)')
    assert_equal -10, @rubic.evaluate('(- 10)')
    assert_equal 1, @rubic.evaluate('(*)')
    assert_equal 10, @rubic.evaluate('(* 10)')
    assert_equal 1/2r, @rubic.evaluate('(/ 2)')
  end

  def test_invalid_arithmetic_operations
    assert_raises ::Rubic::ArgumentError do
      @rubic.evaluate('(-)')
    end
    assert_raises ::Rubic::ArgumentError do
      @rubic.evaluate('(/)')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate("(+ 'a 'b)")
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate("(- 'a 'b)")
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate("(* 'a 'b)")
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate("(/ 'a 'b)")
    end
  end

  def test_comparators
    assert @rubic.evaluate('(= 10 10)')
    refute @rubic.evaluate('(= 10 11)')
    assert @rubic.evaluate('(= 10 10 10)')
    refute @rubic.evaluate('(= 10 11 10)')

    refute @rubic.evaluate('(< 10 9)')
    refute @rubic.evaluate('(< 10 10)')
    assert @rubic.evaluate('(< 10 11)')
    assert @rubic.evaluate('(< 9 10 11)')
    refute @rubic.evaluate('(< 9 10 10)')

    assert @rubic.evaluate('(> 10 9)')
    refute @rubic.evaluate('(> 10 10)')
    refute @rubic.evaluate('(> 10 11)')
    assert @rubic.evaluate('(> 11 10 9)')
    refute @rubic.evaluate('(> 11 11 10)')

    refute @rubic.evaluate('(<= 10 9)')
    assert @rubic.evaluate('(<= 10 10)')
    assert @rubic.evaluate('(<= 10 11)')
    assert @rubic.evaluate('(<= 9 10 11)')
    assert @rubic.evaluate('(<= 9 10 10)')
    refute @rubic.evaluate('(<= 9 10 9)')

    assert @rubic.evaluate('(>= 10 9)')
    assert @rubic.evaluate('(>= 10 10)')
    refute @rubic.evaluate('(>= 10 11)')
    assert @rubic.evaluate('(>= 11 10 9)')
    assert @rubic.evaluate('(>= 11 11 10)')
    refute @rubic.evaluate('(>= 11 10 11)')
  end

  def test_invalid_comparision
    assert_raises ::Rubic::ArgumentError do
      @rubic.evaluate('(=)')
    end
    assert_raises ::Rubic::ArgumentError do
      @rubic.evaluate('(= 1)')
    end

    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(< (list 1) (list 2))')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(> (list 2) (list 1))')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(= (list 1) (list 1))')
    end
  end

  def test_predicates
    assert @rubic.evaluate('(number? 3+4i)')
    assert @rubic.evaluate('(number? 3)')
    assert @rubic.evaluate('(complex? 3+4i)')
    assert @rubic.evaluate('(complex? 3)')
    assert @rubic.evaluate('(real? 3)')
    assert @rubic.evaluate('(real? -2.5+0.0i)')
    assert @rubic.evaluate('(real? #e1e10)')
    assert @rubic.evaluate('(rational? 6/10)')
    assert @rubic.evaluate('(rational? 6/3)')
    assert @rubic.evaluate('(integer? 3+0i)')
    assert @rubic.evaluate('(integer? 3.0)')
    assert @rubic.evaluate('(integer? 8/4)')

    refute @rubic.evaluate("(number? 'abc)")
    refute @rubic.evaluate('(number? (list 1))')
  end

  def test_exactness_predicates
    assert @rubic.evaluate('(exact? 1)')
    refute @rubic.evaluate('(exact? 1.0)')
    refute @rubic.evaluate('(exact? 0.1)')
    assert @rubic.evaluate('(exact? 1/2)')
    assert @rubic.evaluate('(exact? 3+4i)')
    refute @rubic.evaluate('(exact? 0.5+2i)')

    refute @rubic.evaluate('(inexact? 1)')
    assert @rubic.evaluate('(inexact? 1.0)')
    assert @rubic.evaluate('(inexact? 0.1)')
    refute @rubic.evaluate('(inexact? 1/2)')
    refute @rubic.evaluate('(inexact? 3+4i)')
    assert @rubic.evaluate('(inexact? 0.5+2i)')

    refute @rubic.evaluate("(exact? 'abc)")
    refute @rubic.evaluate("(inexact? 'abc)")
  end

  def test_numerical_predicates
    assert @rubic.evaluate('(zero? 0)')
    assert @rubic.evaluate('(zero? 0.0)')
    refute @rubic.evaluate('(zero? 1.0)')
    refute @rubic.evaluate('(zero? 1+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(zero? 'abc)")
    end

    assert @rubic.evaluate('(positive? 1.0)')
    refute @rubic.evaluate('(positive? -1.0)')
    refute @rubic.evaluate('(positive? 0.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(positive? 1+i)')
    end

    assert @rubic.evaluate('(negative? -1.0)')
    refute @rubic.evaluate('(negative? 1.0)')
    refute @rubic.evaluate('(negative? 0.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(negative? 1+i)')
    end

    assert @rubic.evaluate('(odd? 3.0)')
    refute @rubic.evaluate('(odd? 2.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(odd? 1.5)')
    end

    assert @rubic.evaluate('(even? 2.0)')
    refute @rubic.evaluate('(even? 3.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(even? 1.5)')
    end
  end

  def test_max_and_min
    assert_equal 3, @rubic.evaluate('(max 1 2 3)')
    assert_equal 1, @rubic.evaluate('(max 1)')
    assert_same 3.0, @rubic.evaluate('(max 3 1.2 2.5)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(max 1 2 1+i)")
    end

    assert_equal 1, @rubic.evaluate('(min 1 2 3)')
    assert_equal 1, @rubic.evaluate('(min 1)')
    assert_same 1.0, @rubic.evaluate('(min 3.2 1 2.7)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(min 1+i 2 3)')
    end
  end

  def test_abs
    assert_equal 7, @rubic.evaluate('(abs -7)')
    assert_equal 7, @rubic.evaluate('(abs 7)')
    assert_equal 1/2r, @rubic.evaluate('(abs -1/2)')
    assert_equal 1.4142135623730951, @rubic.evaluate('(abs 1+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(abs 'abc)")
    end
  end

  def test_integer_division_procedures
    assert_equal 3, @rubic.evaluate('(quotient 13 4)')
    assert_equal -3, @rubic.evaluate('(quotient -13 4)')
    assert_equal -3, @rubic.evaluate('(quotient 13 -4)')
    assert_equal 3, @rubic.evaluate('(quotient -13 -4)')
    assert_same 3.0, @rubic.evaluate('(quotient -13 -4.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(quotient 13.1 4)')
    end

    assert_equal 1, @rubic.evaluate('(modulo 13 4)')
    assert_equal 3, @rubic.evaluate('(modulo -13 4)')
    assert_equal -3, @rubic.evaluate('(modulo 13 -4)')
    assert_equal -1, @rubic.evaluate('(modulo -13 -4)')
    assert_same -1.0, @rubic.evaluate('(modulo -13 -4.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(modulo 13.1 4)')
    end

    assert_equal 1, @rubic.evaluate('(remainder 13 4)')
    assert_equal -1, @rubic.evaluate('(remainder -13 4)')
    assert_equal 1, @rubic.evaluate('(remainder 13 -4)')
    assert_equal -1, @rubic.evaluate('(remainder -13 -4)')
    assert_same -1.0, @rubic.evaluate('(remainder -13 -4.0)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(remainder 13.1 4)')
    end
  end

  def test_gcd_and_lcm
    assert_equal 4, @rubic.evaluate('(gcd 32 -36)')
    assert_equal 7, @rubic.evaluate('(gcd 14 56 49)')
    assert_equal 3, @rubic.evaluate('(gcd 3)')
    assert_equal 0, @rubic.evaluate('(gcd)')
    assert_same 4.0, @rubic.evaluate('(gcd 32.0 36)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(gcd 20 2.5)')
    end

    assert_equal 288, @rubic.evaluate('(lcm 32 -36)')
    assert_equal 392, @rubic.evaluate('(lcm 14 56 49)')
    assert_equal 3, @rubic.evaluate('(lcm 3)')
    assert_equal 1, @rubic.evaluate('(lcm)')
    assert_same 288.0, @rubic.evaluate('(lcm 32.0 36)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(lcm 20 2.5)')
    end
  end

  def test_fractional_procedures
    assert_equal 3, @rubic.evaluate('(numerator (/ 6 4))')
    assert_equal -1, @rubic.evaluate('(numerator -1/3)')
    assert_same 3.0, @rubic.evaluate('(numerator (exact->inexact (/ 6 4)))')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(numerator 0+i)')
    end

    assert_equal 2, @rubic.evaluate('(denominator (/ 6 4))')
    assert_equal 3, @rubic.evaluate('(denominator -1/3)')
    assert_same 2.0, @rubic.evaluate('(denominator (exact->inexact (/ 6 4)))')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(denominator 0+i)')
    end
  end

  def test_rounding_procedures
    assert_equal 3.0, @rubic.evaluate('(floor 3.5)')
    assert_equal -5.0, @rubic.evaluate('(floor -4.3)')
    assert_same 3, @rubic.evaluate('(floor 7/2)')
    assert_same 7, @rubic.evaluate('(floor 7)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(floor 0+i)')
    end

    assert_equal 4.0, @rubic.evaluate('(ceiling 3.5)')
    assert_equal -4.0, @rubic.evaluate('(ceiling -4.3)')
    assert_same 4, @rubic.evaluate('(ceiling 7/2)')
    assert_same 7, @rubic.evaluate('(ceiling 7)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(ceiling 0+i)')
    end

    assert_equal 3.0, @rubic.evaluate('(truncate 3.5)')
    assert_equal -4.0, @rubic.evaluate('(truncate -4.3)')
    assert_same 3, @rubic.evaluate('(truncate 7/2)')
    assert_same 7, @rubic.evaluate('(truncate 7)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(truncate 0+i)')
    end

    assert_equal 4.0, @rubic.evaluate('(round 3.5)')
    assert_equal -4.0, @rubic.evaluate('(round -4.3)')
    assert_same 4, @rubic.evaluate('(round 7/2)')
    assert_same 7, @rubic.evaluate('(round 7)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(round 0+i)')
    end
  end

  def test_rationalize
    assert_equal 1/3r, @rubic.evaluate('(rationalize (inexact->exact .3) 1/10)')
    assert_equal @rubic.evaluate('#i1/3'), @rubic.evaluate('(rationalize .3 1/10)')
    assert_same 7, @rubic.evaluate('(rationalize 7 1/10)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate('(rationalize 0+i 1/10)')
    end
  end

  def test_transcendental_function_procedures
    assert_in_delta 2.718281828459045, @rubic.evaluate('(exp 1)')
    assert_in_delta Complex(0.5403023058681398, 0.8414709848078965), @rubic.evaluate('(exp 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(exp 'abc)")
    end

    assert_in_delta 0.0, @rubic.evaluate('(log 1)')
    assert_in_delta Complex(0.0, 1.5707963267948966), @rubic.evaluate('(log 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(log 'abc)")
    end

    assert_in_delta 0.8414709848078965, @rubic.evaluate('(sin 1)')
    assert_in_delta Complex(0.0, 1.1752011936438014), @rubic.evaluate('(sin 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(sin 'abc)")
    end

    assert_in_delta 0.5403023058681398, @rubic.evaluate('(cos 1)')
    assert_in_delta 1.5430806348152437, @rubic.evaluate('(cos 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(cos 'abc)")
    end

    assert_in_delta 1.557407724654902, @rubic.evaluate('(tan 1)')
    assert_in_delta Complex(0.0, 0.7615941559557649), @rubic.evaluate('(tan 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(tan 'abc)")
    end

    assert_in_delta 1.5707963267948966, @rubic.evaluate('(asin 1)')
    assert_in_delta Complex(0.0, 0.8813735870195428), @rubic.evaluate('(asin 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(asin 'abc)")
    end

    assert_in_delta 0.0, @rubic.evaluate('(acos 1)')
    assert_in_delta Complex(1.5707963267948966, -0.8813735870195428), @rubic.evaluate('(acos 0+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(acos 'abc)")
    end

    assert_in_delta 0.7853981633974483, @rubic.evaluate('(atan 1)')
    assert_in_delta 0.4636476090008061, @rubic.evaluate('(atan 1 2)')
    assert_in_delta Complex(1.0172219678978514, 0.4023594781085251), @rubic.evaluate('(atan 1+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(atan 'abc)")
    end
    assert_raises Rubic::ArgumentError do
      @rubic.evaluate("(atan 1 2 3)")
    end
  end

  def test_exactness_converters
    assert_same 1.0, @rubic.evaluate('(exact->inexact 1)')
    assert_same 1.0, @rubic.evaluate('(exact->inexact 1.0)')
    assert_equal 0.5, @rubic.evaluate('(exact->inexact 1/2)')
    assert_equal Complex(0.5, 1.0), @rubic.evaluate('(exact->inexact 1/2+i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(exact->inexact 'abc)")
    end

    assert_same 1, @rubic.evaluate('(inexact->exact 1)')
    assert_same 1, @rubic.evaluate('(inexact->exact 1.0)')
    assert_equal 1/2r, @rubic.evaluate('(inexact->exact 0.5)')
    assert_equal Complex(1/2r, 1), @rubic.evaluate('(inexact->exact 0.5+1.0i)')
    assert_raises Rubic::TypeError do
      @rubic.evaluate("(inexact->exact 'abc)")
    end
  end
end
