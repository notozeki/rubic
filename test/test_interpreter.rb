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
    assert_equal 57, @rubic.evaluate(<<-SCHEME)
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

    @rubic.evaluate(<<-SCHEME)
      (define (sum-of-squares x y)
        (+ (square x) (square y)))
    SCHEME
    assert_equal 25, @rubic.evaluate('(sum-of-squares 3 4)')

    @rubic.evaluate(<<-SCHEME)
      (define (f a)
        (sum-of-squares (+ a 1) (* a 2)))
    SCHEME
    assert_equal 136, @rubic.evaluate('(f 5)')
  end

  def test_evaluate_cond_statement
    @rubic.evaluate(<<-SCHEME)
      (define (abs x)
        (cond ((> x 0) x)
              ((= x 0) 0)
              ((< x 0) (- x))))
    SCHEME
    assert_equal 10, @rubic.evaluate('(abs 10)')
    assert_equal 0,  @rubic.evaluate('(abs 0)')
    assert_equal 10, @rubic.evaluate('(abs (- 0 10))')

    @rubic.evaluate(<<-SCHEME)
      (define (abs x)
        (cond ((< x 0) (- x))
              (else x)))
    SCHEME
    assert_equal 10, @rubic.evaluate('(abs 10)')
    assert_equal 0,  @rubic.evaluate('(abs 0)')
    assert_equal 10, @rubic.evaluate('(abs (- 0 10))')
  end

  def test_evaluate_if_statement
    @rubic.evaluate(<<-SCHEME)
      (define (abs x)
        (if (< x 0)
            (- x)
            x))
    SCHEME
    assert_equal 10, @rubic.evaluate('(abs 10)')
    assert_equal 0,  @rubic.evaluate('(abs 0)')
    assert_equal 10, @rubic.evaluate('(abs (- 0 10))')
  end

  def test_evaluate_predicate_expressions
    @rubic.evaluate('(define x 7)')
    assert_equal true, @rubic.evaluate('(and (> x 5) (< x 10))')
    @rubic.evaluate('(define x 1)')
    assert_equal false, @rubic.evaluate('(and (> x 5) (< x 10))')

    @rubic.evaluate(<<-SCHEME)
      (define (>= x y)
        (or (> x y) (= x y)))
    SCHEME
    assert_equal true,  @rubic.evaluate('(>= 11 10)')
    assert_equal true,  @rubic.evaluate('(>= 10 10)')
    assert_equal false, @rubic.evaluate('(>= 9 10)')

    @rubic.evaluate(<<-SCHEME)
      (define (>= x y)
        (not (< x y)))
    SCHEME
    assert_equal true,  @rubic.evaluate('(>= 11 10)')
    assert_equal true,  @rubic.evaluate('(>= 10 10)')
    assert_equal false, @rubic.evaluate('(>= 9 10)')
  end

  def test_evaluate_operator_as_compound_expression
    @rubic.evaluate(<<-SCHEME)
      (define (a-plus-abs-b a b)
        ((if (> b 0) + -) a b))
    SCHEME
    assert_equal 11, @rubic.evaluate('(a-plus-abs-b 1 (- 10))')
  end

  def test_evaluate_block_structure
    @rubic.evaluate(<<-SCHEME)
      (define (sqrt x)
        (define (square x) (* x x))
        (define (abs x)
          (if (< x 0) (- x) x))
        (define (average x y)
          (/ (+ x y) 2))
        (define (good-enough? guess)
          (< (abs (- (square guess) x)) 0.001))
        (define (improve guess)
          (average guess (/ x guess)))
        (define (sqrt-iter guess)
          (if (good-enough? guess)
              guess
              (sqrt-iter (improve guess))))
        (sqrt-iter 1.0))
    SCHEME
    assert_equal 3.00009155413138, @rubic.evaluate('(sqrt 9)')
    assert_raises ::Rubic::RubicRuntimeError do
      # can't see `good-enough?` in global scope
      @rubic.evaluate('(good-enough? 10)')
    end
  end

  def test_evaluate_lambda_expression
    @rubic.evaluate('(define (square x) (* x x))')
    assert_equal 12, @rubic.evaluate('((lambda (x y z) (+ x y (square z))) 1 2 3)')

    @rubic.evaluate(<<-SCHEME)
      (define (sum term a next b)
        (if (> a b)
            0
            (+ (term a)
               (sum term (next a) next b))))
    SCHEME
    @rubic.evaluate(<<-SCHEME)
      (define (pi-sum a b)
        (sum (lambda (x) (/ 1.0 (* x (+ x 2))))
             a
             (lambda (x) (+ x 4))
             b))
    SCHEME
    assert_equal 3.139592655589783, @rubic.evaluate('(* 8 (pi-sum 1 1000))')

    @rubic.evaluate(<<-SCHEME)
      (define (integral f a b dx)
        (* (sum f
                (+ a (/ dx 2.0))
                (lambda (x) (+ x dx))
                b)
           dx))
    SCHEME
    @rubic.evaluate('(define (cube x) (* x x x))')
    assert_equal 0.24998750000000042, @rubic.evaluate('(integral cube 0 1 0.01)')
  end
end
