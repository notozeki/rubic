require 'minitest_helper'
require 'rubic'

class TestList < MiniTest::Test
  def setup
    @rubic = Rubic::Interpreter.new
  end

  def test_basic_list_operations
    @rubic.evaluate('(define x (cons 1 2))')
    assert_equal 1, @rubic.evaluate('(car x)')
    assert_equal 2, @rubic.evaluate('(cdr x)')

    @rubic.evaluate('(define x (cons 1 2))')
    @rubic.evaluate('(define y (cons 3 4))')
    @rubic.evaluate('(define z (cons x y))')
    assert_equal 1, @rubic.evaluate('(car (car z))')
    assert_equal 3, @rubic.evaluate('(car (cdr z))')
  end

  def test_invalid_list_operations
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
  end

  def test_list_construction
    assert_equal @rubic.evaluate('(cons 1 (cons 2 (cons 3 nil)))'),
                 @rubic.evaluate('(list 1 2 3)')
  end

  def test_practical_list_operations
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
end
