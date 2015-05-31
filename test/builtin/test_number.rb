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
    assert @rubic.evaluate('(exact? 1.0)')
    refute @rubic.evaluate('(exact? 0.1)')
    assert @rubic.evaluate('(exact? 1/2)')
    assert @rubic.evaluate('(exact? 3+4i)')
    refute @rubic.evaluate('(exact? 0.5+2i)')

    refute @rubic.evaluate('(inexact? 1)')
    refute @rubic.evaluate('(inexact? 1.0)')
    assert @rubic.evaluate('(inexact? 0.1)')
    refute @rubic.evaluate('(inexact? 1/2)')
    refute @rubic.evaluate('(inexact? 3+4i)')
    assert @rubic.evaluate('(inexact? 0.5+2i)')

    refute @rubic.evaluate("(exact? 'abc)")
    refute @rubic.evaluate("(inexact? 'abc)")
  end
end
