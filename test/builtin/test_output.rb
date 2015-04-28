require 'minitest_helper'
require 'rubic'

class TestOutput < MiniTest::Test
  def setup
    @rubic = Rubic::Interpreter.new
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
