require 'test_helper'

class DecisionMakerTest < Test::Unit::TestCase
  def test_process_input_pattern
    decision_maker = DecisionMaker.new()

    assert_nothing_raised do
      decision_maker.process_input_pattern("sense name", [["some value",5],["new value",1]])
    end
  end
end
