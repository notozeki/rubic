require 'minitest_helper'
require 'rubic/parser'

class TestParser < MiniTest::Test
  def setup
    @parser = ::Rubic::Parser.new
  end

  def parse_expr(str)
    @parser.parse(str).first
  end

  def test_parse_expressions
    assert_equal 486,                 parse_expr('486')
    assert_equal [:+, 137, 349],      parse_expr('(+ 137 349)')
    assert_equal [:-, 1000, 334],     parse_expr('(- 1000 334)')
    assert_equal [:*, 5, 99],         parse_expr('(* 5 99)')
    assert_equal [:/, 10, 5],         parse_expr('(/ 10 5)')
    assert_equal [:+, 2.7, 10],       parse_expr('(+ 2.7 10)')
    assert_equal [:+, 21, 35, 12, 7], parse_expr('(+ 21 35 12 7)')
    assert_equal [:*, 25, 4, 12],     parse_expr('(* 25 4 12)')
  end

  def test_parse_nested_expressions
    assert_equal [:+, [:*, 3, 5], [:-, 10, 6]],
                 parse_expr('(+ (* 3 5) (- 10 6))')
    assert_equal [:+, [:*, 3, [:+, [:*, 2, 4], [:+, 3, 5]]], [:+, [:-, 10, 7], 6]],
                 parse_expr('(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))')
    assert_equal [:+, [:*, 3, [:+, [:*, 2, 4], [:+, 3, 5]]], [:+, [:-, 10, 7], 6]],
                 parse_expr(<<-SCHEME)
      (+ (* 3
            (+ (* 2 4)
               (+ 3 5)))
         (+ (- 10 7)
            6))
    SCHEME
  end

  def test_parse_define_statement
    assert_equal [:define, :size, 2],     parse_expr('(define size 2)')
    assert_equal [:define, :pi, 3.14159], parse_expr('(define pi 3.14159)')
    assert_equal [:define, :radius, 10],  parse_expr('(define radius 10)')
    assert_equal [:define, :circumference, [:*, 2, :pi, :radius]],
                 parse_expr('(define circumference (* 2 pi radius))')
  end

  def test_parse_procedure_definitions
    assert_equal [:define, [:square, :x], [:*, :x, :x]],
                 parse_expr('(define (square x) (* x x))')
    assert_equal [:define, [:'sum-of-squares', :x, :y], [:+, [:square, :x], [:square, :y]]],
                 parse_expr(<<-SCHEME)
      (define (sum-of-squares x y)
        (+ (square x) (square y)))
    SCHEME
    assert_equal [:define, [:f, :a], [:'sum-of-squares', [:+, :a, 1], [:*, :a, 2]]],
                 parse_expr(<<-SCHEME)
      (define (f a)
        (sum-of-squares (+ a 1) (* a 2)))
    SCHEME
  end

  def test_parse_cond_statement
    assert_equal [:cond, [[:>, :x, 0], :x], [[:'=', :x, 0], 0], [[:<, :x, 0], [:-, :x]]],
                 parse_expr(<<-SCHEME)
      (cond ((> x 0) x)
            ((= x 0) 0)
            ((< x 0) (- x)))
    SCHEME
    assert_equal [:cond, [[:<, :x, 0], [:-, :x]], [:else, :x]],
                 parse_expr(<<-SCHEME)
      (cond ((< x 0) (- x))
            (else x))
    SCHEME
  end

  def test_parse_if_statement
    assert_equal [:if, [:<, :x, 0], [:-, :x], :x],
                 parse_expr(<<-SCHEME)
      (if (< x 0)
          (- x)
          x)
    SCHEME
  end

  def test_predicate_expressions
    assert_equal [:and, [:>, :x, 5], [:<, :x, 10]],
                 parse_expr('(and (> x 5) (< x 10))')
    assert_equal [:or, [:>, :x, :y], [:'=', :x, :y]],
                 parse_expr('(or (> x y) (= x y))')
  end

  def test_parse_lambda_expression
    assert_equal [:lambda, [:x], [:+, :x, 4]],
                 parse_expr('(lambda (x) (+ x 4))')
    assert_equal [:lambda, [:x, :y, :z], [:+, :x, :y, [:square, :z]]],
                 parse_expr('(lambda (x y z) (+ x y (square z)))')
  end

  def test_parse_let_expression
    assert_equal [:let, [[:x, 3], [:y, [:+, :x, 2]]], [:*, :x, :y]],
                 parse_expr(<<-SCHEME)
      (let ((x 3)
           (y (+ x 2)))
        (* x y))
    SCHEME
  end

  def test_parse_string_literal
    assert_equal 'abc', parse_expr('"abc"')
    assert_equal 'define', parse_expr('"define"')
    assert_equal '', parse_expr('""')
  end

  def test_parse_procedure_call
    assert_equal [:op, :arg1, :arg2], parse_expr('(op arg1 arg2)')
    assert_equal [:'op-no-arg'], parse_expr('(op-no-arg)')
  end

  def test_parse_quote_expression
    assert_equal [:quote, :a], parse_expr('(quote a)')
    assert_equal parse_expr('(quote a)'), parse_expr("'a")
    assert_equal [:quote, [:a, :b, :c]], parse_expr('(quote (a b c))')
    assert_equal parse_expr('(quote (a b c))'), parse_expr("'(a b c)")
    assert_equal [:quote, []], parse_expr('(quote ())')
    assert_equal parse_expr('(quote ())'), parse_expr("'()")
  end

  def test_parse_sequence
    assert_equal [123, [:define, :x, 234], :x], @parser.parse(<<-SCHEME)
      123
      (define x 234)
      x
    SCHEME
    assert_equal [], @parser.parse('')
  end
end
