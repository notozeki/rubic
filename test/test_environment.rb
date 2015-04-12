require 'minitest_helper'
require 'rubic/environment'

class TestEnvironment < MiniTest::Test
  def setup
    @env = ::Rubic::Environment.new
  end

  def test_simple_definition
    @env.defvar('x', 100)
    assert_equal 100, @env.refvar('x')
  end

  def test_nested_environment
    local = ::Rubic::Environment.new(@env)
    @env.defvar('x', 100)
    assert_equal 100, local.refvar('x')

    local.defvar('x', 10)
    assert_equal 10, local.refvar('x')
  end

  def test_refers_undefined_variable_raises_exception
    assert_raises ::Rubic::RubicRuntimeError do
      @env.refvar('x')
    end
  end

  def test_bind_arguments
    @env.bind(['x', 'y'], [10, 20])
    assert_equal 10, @env.refvar('x')
    assert_equal 20, @env.refvar('y')
  end

  def test_bind_wrong_number_of_arguments_raises_exception
    assert_raises ::Rubic::RubicRuntimeError do
      @env.bind(['x', 'y', 'z'], [10, 20])
    end
  end
end
