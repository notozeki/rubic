require 'minitest_helper'
require 'rubic/parser'

class TestParser < MiniTest::Test
  def setup
    @parser = ::Rubic::Parser.new
  end

  def test_parse_expressions
    assert_equal 486,  @parser.parse('486')
    assert_equal 486,  @parser.parse('(+ 137 349)')
    assert_equal 666,  @parser.parse('(- 1000 334)')
    assert_equal 495,  @parser.parse('(* 5 99)')
    assert_equal 2,    @parser.parse('(/ 10 5)')
    assert_equal 12.7, @parser.parse('(+ 2.7 10)')
    assert_equal 75,   @parser.parse('(+ 21 35 12 7)')
    assert_equal 1200, @parser.parse('(* 25 4 12)')
  end

  def test_parse_nested_expressions
    assert_equal 19, @parser.parse('(+ (* 3 5) (- 10 6))')
    assert_equal 57, @parser.parse('(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))')
    assert_equal 57, @parser.parse(<<SCHEME)
(+ (* 3
      (+ (* 2 4)
         (+ 3 5)))
   (+ (- 10 7)
      6))
SCHEME
  end
end
