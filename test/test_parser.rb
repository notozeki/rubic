require 'minitest_helper'
require 'rubic/parser'

class TestParser < MiniTest::Test
  def setup
    @parser = ::Rubic::Parser.new
  end

  def test_parse_expressions
    assert_equal 486,                  @parser.parse('486')
    assert_equal [:+, 137, 349],      @parser.parse('(+ 137 349)')
    assert_equal [:-, 1000, 334],     @parser.parse('(- 1000 334)')
    assert_equal [:*, 5, 99],         @parser.parse('(* 5 99)')
    assert_equal [:/, 10, 5],         @parser.parse('(/ 10 5)')
    assert_equal [:+, 2.7, 10],       @parser.parse('(+ 2.7 10)')
    assert_equal [:+, 21, 35, 12, 7], @parser.parse('(+ 21 35 12 7)')
    assert_equal [:*, 25, 4, 12],     @parser.parse('(* 25 4 12)')
  end

  def test_parse_nested_expressions
    assert_equal [:+, [:*, 3, 5], [:-, 10, 6]],
                 @parser.parse('(+ (* 3 5) (- 10 6))')
    assert_equal [:+, [:*, 3, [:+, [:*, 2, 4], [:+, 3, 5]]], [:+, [:-, 10, 7], 6]],
                 @parser.parse('(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))')
    assert_equal [:+, [:*, 3, [:+, [:*, 2, 4], [:+, 3, 5]]], [:+, [:-, 10, 7], 6]],
                 @parser.parse(<<-SCHEME)
      (+ (* 3
            (+ (* 2 4)
               (+ 3 5)))
         (+ (- 10 7)
            6))
    SCHEME
  end

  def test_parse_define_statement
    assert_equal [:define, :size, 2],     @parser.parse('(define size 2)')
    assert_equal [:define, :pi, 3.14159], @parser.parse('(define pi 3.14159)')
    assert_equal [:define, :radius, 10],  @parser.parse('(define radius 10)')
    assert_equal [:define, :circumference, [:*, 2, :pi, :radius]],
                 @parser.parse('(define circumference (* 2 pi radius))')
  end

  def test_parse_procedure_definitions
    assert_equal [:define, [:square, :x], [:*, :x, :x]],
                 @parser.parse('(define (square x) (* x x))')
    assert_equal [:define, [:'sum-of-squares', :x, :y], [:+, [:square, :x], [:square, :y]]],
                 @parser.parse(<<-SCHEME)
      (define (sum-of-squares x y)
        (+ (square x) (square y)))
    SCHEME
    assert_equal [:define, [:f, :a], [:'sum-of-squares', [:+, :a, 1], [:*, :a, 2]]],
                 @parser.parse(<<-SCHEME)
      (define (f a)
        (sum-of-squares (+ a 1) (* a 2)))
    SCHEME
  end

  def test_parse_cond_statement
    assert_equal [:cond, [[:>, :x, 0], :x], [[:'=', :x, 0], 0], [[:<, :x, 0], [:-, :x]]],
                 @parser.parse(<<-SCHEME)
      (cond ((> x 0) x)
            ((= x 0) 0)
            ((< x 0) (- x)))
    SCHEME
    assert_equal [:cond, [[:<, :x, 0], [:-, :x]], [:else, :x]],
                 @parser.parse(<<-SCHEME)
      (cond ((< x 0) (- x))
            (else x))
    SCHEME
  end

  def test_parse_if_statement
    assert_equal [:if, [:<, :x, 0], [:-, :x], :x],
                 @parser.parse(<<-SCHEME)
      (if (< x 0)
          (- x)
          x)
    SCHEME
  end

  def test_predicate_expressions
    assert_equal [:and, [:>, :x, 5], [:<, :x, 10]],
                 @parser.parse('(and (> x 5) (< x 10))')
    assert_equal [:or, [:>, :x, :y], [:'=', :x, :y]],
                 @parser.parse('(or (> x y) (= x y))')
  end

  def test_parse_lambda_expression
    assert_equal [:lambda, [:x], [:+, :x, 4]],
                 @parser.parse('(lambda (x) (+ x 4))')
    assert_equal [:lambda, [:x, :y, :z], [:+, :x, :y, [:square, :z]]],
                 @parser.parse('(lambda (x y z) (+ x y (square z)))')
  end

  def test_parse_let_expression
    assert_equal [:let, [[:x, 3], [:y, [:+, :x, 2]]], [:*, :x, :y]],
                 @parser.parse(<<-SCHEME)
      (let ((x 3)
           (y (+ x 2)))
        (* x y))
    SCHEME
  end

  def test_parse_string_literal
    assert_equal 'abc', @parser.parse('"abc"')
    assert_equal 'define', @parser.parse('"define"')
    assert_equal '', @parser.parse('""')
  end

  def test_parse_procedure_call
    assert_equal [:op, :arg1, :arg2], @parser.parse('(op arg1 arg2)')
    assert_equal [:'op-no-arg'], @parser.parse('(op-no-arg)')
  end

  def test_parse_quote_expression
    assert_equal [:quote, :a], @parser.parse('(quote a)')
    assert_equal @parser.parse('(quote a)'), @parser.parse("'a")
    assert_equal [:quote, [:a, :b, :c]], @parser.parse('(quote (a b c))')
    assert_equal @parser.parse('(quote (a b c))'), @parser.parse("'(a b c)")
    assert_equal [:quote, []], @parser.parse('(quote ())')
    assert_equal @parser.parse('(quote ())'), @parser.parse("'()")
  end
end
