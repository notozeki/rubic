require 'minitest_helper'
require 'rubic'
require 'rubic/inspector'

class TestInspector < MiniTest::Test
  using ::Rubic::Inspector

  def setup
    @rubic = ::Rubic::Interpreter.new
  end

  def test_inspect_list
    assert_equal '(1 . 2)', @rubic.evaluate('(cons 1 2)').inspect
    assert_equal '(1 2 . 3)', @rubic.evaluate('(cons 1 (cons 2 3))').inspect
    assert_equal '((1 . 2) . 3)', @rubic.evaluate('(cons (cons 1 2) 3)').inspect
    assert_equal '((1 . 2) 3 . 4)', @rubic.evaluate('(cons (cons 1 2) (cons 3 4))').inspect
    assert_equal '(1 2 3 4)', @rubic.evaluate('(list 1 2 3 4)').inspect
    assert_equal '("a" . "b")', @rubic.evaluate('(cons "a" "b")').inspect
  end

  def test_list_to_string
    assert_equal '(1 . 2)', @rubic.evaluate('(cons 1 2)').to_s
    assert_equal '(1 2 . 3)', @rubic.evaluate('(cons 1 (cons 2 3))').to_s
    assert_equal '((1 . 2) . 3)', @rubic.evaluate('(cons (cons 1 2) 3)').to_s
    assert_equal '((1 . 2) 3 . 4)', @rubic.evaluate('(cons (cons 1 2) (cons 3 4))').to_s
    assert_equal '(1 2 3 4)', @rubic.evaluate('(list 1 2 3 4)').to_s
    assert_equal '(a . b)', @rubic.evaluate('(cons "a" "b")').to_s
  end

  def test_inspect_lambda_expression
    assert_match /^#<lambda:.*>/, @rubic.evaluate('(lambda (x) x)').inspect
  end

  def test_lambda_to_string
    assert_match /^#<lambda:.*>/, @rubic.evaluate('(lambda (x) x)').to_s
  end
end
