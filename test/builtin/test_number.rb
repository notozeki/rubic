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
    assert_equal 0, @rubic.evaluate('(/ 2)')
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

  def test_max_and_min_procedures
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
