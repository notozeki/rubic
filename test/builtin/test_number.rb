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
    refute @rubic.evaluate('(< 10 9)')
    refute @rubic.evaluate('(< 10 10)')
    assert @rubic.evaluate('(< 10 11)')

    assert @rubic.evaluate('(> 10 9)')
    refute @rubic.evaluate('(> 10 10)')
    refute @rubic.evaluate('(> 10 11)')

    assert @rubic.evaluate('(= 10 10)')
    refute @rubic.evaluate('(= 10 11)')
  end

  def test_invalid_comparision
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
end
