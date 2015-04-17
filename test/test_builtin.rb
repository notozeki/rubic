require 'minitest_helper'
require 'rubic/interpreter'
require 'rubic/builtin'

class TestBuiltin < MiniTest::Test
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

  def test_list_operations
    @rubic.evaluate('(define x (cons 1 2))')
    assert_equal 1, @rubic.evaluate('(car x)')
    assert_equal 2, @rubic.evaluate('(cdr x)')

    @rubic.evaluate('(define x (cons 1 2))')
    @rubic.evaluate('(define y (cons 3 4))')
    @rubic.evaluate('(define z (cons x y))')
    assert_equal 1, @rubic.evaluate('(car (car z))')
    assert_equal 3, @rubic.evaluate('(car (cdr z))')

    assert_equal @rubic.evaluate('(cons 1 (cons 2 (cons 3 nil)))'),
                 @rubic.evaluate('(list 1 2 3)')

    assert_raises ::Rubic::TypeError do
     @rubic.evaluate('(car 1)')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(car ())')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(cdr 1)')
    end
    assert_raises ::Rubic::TypeError do
      @rubic.evaluate('(cdr ())')
    end

    @rubic.evaluate(<<-SCHEME)
      (define (list-ref items n)
        (if (= n 0)
            (car items)
            (list-ref (cdr items) (- n 1))))
    SCHEME
    assert_equal 16, @rubic.evaluate('(list-ref (list 1 4 9 16 25) 3)')

    @rubic.evaluate(<<-SCHEME)
      (define (length items)
        (if (null? items)
            0
            (+ 1 (length (cdr items)))))
    SCHEME
    assert_equal 4, @rubic.evaluate('(length (list 1 3 5 7))')

    @rubic.evaluate(<<-SCHEME)
      (define (count-leaves x)
        (cond ((null? x) 0)
              ((not (pair? x)) 1)
              (else (+ (count-leaves (car x))
                       (count-leaves (cdr x))))))
    SCHEME
    @rubic.evaluate('(define x (cons (list 1 2) (list 3 4)))')
    assert_equal 4, @rubic.evaluate('(count-leaves x)')
    assert_equal 8, @rubic.evaluate('(count-leaves (list x x))')
  end

  def test_output_procedures
    assert_output('100') { @rubic.evaluate('(display 100)') }
    assert_output("\n") { @rubic.evaluate('(newline)') }

    @rubic.evaluate('(define (make-rat n d) (cons n d))')
    @rubic.evaluate('(define (numer x) (car x))')
    @rubic.evaluate('(define (denom x) (cdr x))')
    @rubic.evaluate(<<-SCHEME)
      (define (print-rat x)
        (newline)
        (display (numer x))
        (display "/")
        (display (denom x)))
    SCHEME
    assert_output("\n1/2") { @rubic.evaluate('(print-rat (make-rat 1 2))') }
  end
end
