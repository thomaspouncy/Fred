require 'test_helper'

class SensoryChannelTest < Test::Unit::TestCase
  def test_initializer
    channel = SensoryChannel.new("name","sensor","sensor_value")

    assert_equal "name", channel.name
    assert_equal "sensor", channel.sensor
    assert_equal "sensor_value", channel.sensor_value
    assert_equal 8, channel.memory_queue.max_queue_length
    assert_equal 1, channel.cycle_length
  end

  def test_can_overwrite_defaults
    channel = SensoryChannel.new("name","sensor","sensor_value",4,6)

    assert_equal 4, channel.memory_queue.max_queue_length
    assert_equal 6, channel.cycle_length
  end

  def test_current_sensor_value
    sensor = stub("sensor_obj",:sensor_value=>"some value")
    channel = SensoryChannel.new("name",sensor,:sensor_value)

    assert_equal "some value", channel.current_sensor_value
  end

  def test_previous_sensor_value
    channel = SensoryChannel.new("name","sensor",:sensor_value)

    assert_nil channel.previous_sensor_value

    channel.memory_queue << ["some value",10]

    assert_equal "some value", channel.previous_sensor_value
  end

  def test_previous_cycle_count
    channel = SensoryChannel.new("name","sensor",:sensor_value)

    assert_nil channel.previous_cycle_count

    channel.memory_queue << ["some value",10]

    assert_equal 10, channel.previous_cycle_count
  end

  def test_update_input_pattern
    sensor = stub("sensor_obj",:sensor_value=>"some value")
    channel = SensoryChannel.new("name",sensor,:sensor_value)

    assert channel.memory_queue.empty?

    channel.update_input_pattern

    assert_equal [["some value",1]], channel.memory_queue

    channel.update_input_pattern

    assert_equal [["some value",2]], channel.memory_queue

    sensor.stubs(:sensor_value).returns("new value")

    channel.update_input_pattern

    assert_equal [["some value",2],["new value",1]], channel.memory_queue
  end

  def test_current_input_pattern
    sensor = stub("sensor_obj",:sensor_value=>"some value")
    channel = SensoryChannel.new("name",sensor,:sensor_value)

    assert channel.memory_queue.empty?

    channel.update_input_pattern

    assert_equal channel.memory_queue, channel.current_input_pattern
  end
end
