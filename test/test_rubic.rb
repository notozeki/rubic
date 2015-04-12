require 'minitest_helper'

class TestRubic < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rubic::VERSION
  end
end
