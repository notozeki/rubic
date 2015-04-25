require 'minitest_helper'
require 'rubic/environment'

class TestEnvironment < MiniTest::Test
  def setup
    @env = ::Rubic::Environment.new
  end

  def test_simple_definition
    @env.defvar(:x, 100)
    assert_equal 100, @env.refvar(:x)
  end

  def test_nested_environment
    local = ::Rubic::Environment.new(@env)
    @env.defvar(:x, 100)
    assert_equal 100, local.refvar(:x)

    local.defvar(:x, 10)
    assert_equal 10, local.refvar(:x)
  end

  def test_refers_undefined_variable_raises_exception
    assert_raises ::Rubic::NameError do
      @env.refvar(:x)
    end
  end

  def test_bind_arguments
    @env.bind([:x, :y], [10, 20])
    assert_equal 10, @env.refvar(:x)
    assert_equal 20, @env.refvar(:y)
  end

  def test_bind_wrong_number_of_arguments_raises_exception
    assert_raises ::Rubic::ArgumentError do
      @env.bind([:x, :y, :z], [10, 20])
    end
  end

  def test_extending
    ext = Class.new do
      def method1; end
      private def method2; end
    end
    @env.extend(ext)
    refute_nil @env.refvar(:method1)
    assert_raises ::Rubic::NameError do
      # private methods are not visible
      @env.refvar(:method2)
    end
  end

  def test_assignment
    @env.defvar(:x, 0)
    @env.assign(:x, 100)
    assert_equal 100, @env.refvar(:x)

    local = ::Rubic::Environment.new(@env)
    local.assign(:x, 200)
    assert_equal 200, local.refvar(:x)
    assert_equal 200, @env.refvar(:x)

    assert_raises ::Rubic::NameError do
      local.assign(:y, 100)
    end
  end
end
