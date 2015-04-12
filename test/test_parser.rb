require 'minitest_helper'
require 'rubic/parser'

class TestParser < MiniTest::Test
  def setup
    @parser = ::Rubic::Parser.new
  end

  def test_parse_expressions
    assert_equal 486,                  @parser.parse('486')
    assert_equal ['+', 137, 349],      @parser.parse('(+ 137 349)')
    assert_equal ['-', 1000, 334],     @parser.parse('(- 1000 334)')
    assert_equal ['*', 5, 99],         @parser.parse('(* 5 99)')
    assert_equal ['/', 10, 5],         @parser.parse('(/ 10 5)')
    assert_equal ['+', 2.7, 10],       @parser.parse('(+ 2.7 10)')
    assert_equal ['+', 21, 35, 12, 7], @parser.parse('(+ 21 35 12 7)')
    assert_equal ['*', 25, 4, 12],     @parser.parse('(* 25 4 12)')
  end

  def test_parse_nested_expressions
    assert_equal ['+', ['*', 3, 5], ['-', 10, 6]],
                 @parser.parse('(+ (* 3 5) (- 10 6))')
    assert_equal ['+', ['*', 3, ['+', ['*', 2, 4], ['+', 3, 5]]], ['+', ['-', 10, 7], 6]],
                 @parser.parse('(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))')
    assert_equal ['+', ['*', 3, ['+', ['*', 2, 4], ['+', 3, 5]]], ['+', ['-', 10, 7], 6]],
                 @parser.parse(<<SCHEME)
(+ (* 3
      (+ (* 2 4)
         (+ 3 5)))
   (+ (- 10 7)
      6))
SCHEME
  end

  def test_parse_define_statement
    assert_equal [:define, 'size', 2],     @parser.parse('(define size 2)')
    assert_equal [:define, 'pi', 3.14159], @parser.parse('(define pi 3.14159)')
    assert_equal [:define, 'radius', 10],  @parser.parse('(define radius 10)')
    assert_equal [:define, 'circumference', ['*', 2, 'pi', 'radius']],
                 @parser.parse('(define circumference (* 2 pi radius))')
  end

  def test_parse_procedure_definitions
    assert_equal [:define_proc, ['square', 'x'], ['*', 'x', 'x']],
                 @parser.parse('(define (square x) (* x x))')
    assert_equal [:define_proc, ['sum-of-squares', 'x', 'y'], ['+', ['square', 'x'], ['square', 'y']]],
                 @parser.parse(<<SCHEME)
(define (sum-of-squares x y)
  (+ (square x) (square y)))
SCHEME
    assert_equal [:define_proc, ['f', 'a'], ['sum-of-squares', ['+', 'a', 1], ['*', 'a', 2]]],
                 @parser.parse(<<SCHEME)
(define (f a)
  (sum-of-squares (+ a 1) (* a 2)))
SCHEME
  end

  def test_parse_cond_statement
    assert_equal [:cond, [['>', 'x', 0], 'x'], [['=', 'x', 0], 0], [['<', 'x', 0], ['-', 'x']]],
                 @parser.parse(<<SCHEME)
(cond ((> x 0) x)
      ((= x 0) 0)
      ((< x 0) (- x)))
SCHEME
    assert_equal [:cond, [['<', 'x', 0], ['-', 'x']], [:else, 'x']],
                 @parser.parse(<<SCHEME)
(cond ((< x 0) (- x))
      (else x))
SCHEME
  end
end
