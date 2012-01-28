require 'test_helper'
require 'thread'

class BodyTest < Test::Unit::TestCase
  def setup
    sensor1 = stub("sensor1", :sensor_value=>"value1")
    sensor2 = stub("sensor2", :sensor_value=>"value2")

    @first_channel = SensoryChannel.new("channel_1",sensor1,:sensor_value)
    @second_channel = SensoryChannel.new("channel_2",sensor2,:sensor_value)
    @sensory_channels = [@first_channel,@second_channel]

    @cns = DecisionMaker.new()
    @reflexes = DecisionMaker.new()
  end

  def test_initializer
    body = Body.new(@sensory_channels,@cns,@reflexes)

    assert_equal @sensory_channels, body.sensory_channels
    assert_equal @cns, body.central_nervous_system
    assert_equal @reflexes, body.reflexes

    assert_equal [], body.running_threads
    assert_not_nil body.mutex
    assert_not_nil body.condition_variables
  end

  def test_senses_initialized?
    body = Body.new(@sensory_channels,@cns,@reflexes)

    assert !body.senses_initialized?

    body.initialize_senses
    body.die

    assert body.senses_initialized?
  end

  def test_initialize_senses
    body = Body.new(@sensory_channels,@cns,@reflexes)

    # body.expects(:send_to_reflexes).with("channel1",[["value1",1]]).once.returns(true)
    # body.expects(:send_to_reflexes).with("channel2",[["value2",1]]).once.returns(true)
#
    # body.expects(:send_to_cns).with("channel1",[["value1",1]]).once.returns(true)
    # body.expects(:send_to_cns).with("channel2",[["value2",1]]).once.returns(true)

    body.initialize_senses

    assert_equal 2, body.running_threads.count

    body.die

    assert_raise RuntimeError do
      body.initialize_senses
    end
  end

  def test_send_to_reflexes

  end

  def test_send_to_cns

  end

  def test_die

  end
end
