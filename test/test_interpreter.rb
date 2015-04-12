require 'minitest_helper'
require 'rubic/interpreter'

class TestInterpreter < Minitest::Test
  def setup
    @rubic = ::Rubic::Interpreter.new
  end

  def test_evaluate_expressions
    assert_equal 486,  @rubic.evaluate('486')
    assert_equal 486,  @rubic.evaluate('(+ 137 349)')
    assert_equal 666,  @rubic.evaluate('(- 1000 334)')
    assert_equal 495,  @rubic.evaluate('(* 5 99)')
    assert_equal 2,    @rubic.evaluate('(/ 10 5)')
    assert_equal 12.7, @rubic.evaluate('(+ 2.7 10)')
    assert_equal 75,   @rubic.evaluate('(+ 21 35 12 7)')
    assert_equal 1200, @rubic.evaluate('(* 25 4 12)')
  end

  def test_evaluate_nested_expressions
    assert_equal 19, @rubic.evaluate('(+ (* 3 5) (- 10 6))')
    assert_equal 57, @rubic.evaluate('(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))')
    assert_equal 57, @rubic.evaluate(<<SCHEME)
(+ (* 3
      (+ (* 2 4)
         (+ 3 5)))
   (+ (- 10 7)
      6))
SCHEME
  end

  def test_evaluate_define_statement
    @rubic.evaluate('(define size 2)')
    assert_equal 2, @rubic.evaluate('size')

    @rubic.evaluate('(define pi 3.14159)')
    @rubic.evaluate('(define radius 10)')
    assert_equal 314.159, @rubic.evaluate('(* pi (* radius radius))')

    @rubic.evaluate('(define circumference (* 2 pi radius))')
    assert_equal 62.8318, @rubic.evaluate('circumference')
  end

  def test_evaluate_procedure_definitions
    @rubic.evaluate('(define (square x) (* x x))')
    assert_equal 441, @rubic.evaluate('(square 21)')
    assert_equal 49,  @rubic.evaluate('(square (+ 2 5))')
    assert_equal 81,  @rubic.evaluate('(square (square 3))')

    @rubic.evaluate(<<SCHEME)
(define (sum-of-squares x y)
  (+ (square x) (square y)))
SCHEME
    assert_equal 25, @rubic.evaluate('(sum-of-squares 3 4)')

    @rubic.evaluate(<<SCHEME)
(define (f a)
  (sum-of-squares (+ a 1) (* a 2)))
SCHEME
    assert_equal 136, @rubic.evaluate('(f 5)')
  end

  def test_evaluate_cond_statement
    @rubic.evaluate(<<SCHEME)
(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
SCHEME
    assert_equal 10, @rubic.evaluate('(abs 10)')
    assert_equal 0,  @rubic.evaluate('(abs 0)')
    assert_equal 10, @rubic.evaluate('(abs (- 0 10))')

    @rubic.evaluate(<<SCHEME)
(define (abs x)
  (cond ((< x 0) (- x))
        (else x)))
SCHEME
    assert_equal 10, @rubic.evaluate('(abs 10)')
    assert_equal 0,  @rubic.evaluate('(abs 0)')
    assert_equal 10, @rubic.evaluate('(abs (- 0 10))')
  end
end
