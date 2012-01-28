class SensoryChannel
  DEFAULT_MAX_QUEUE_LENGTH 	  = 8
  DEFAULT_CYCLE_LENGTH				= 1

  attr_reader :name,
              :sensor,
              :sensor_value,
              :memory_queue, 						# An array of prior values for pattern matching. Each entry is formatted [value,number_of_cycles_value_has_been_recorded]
              :cycle_length

  def initialize(name,sensor,sensor_value,max_queue_length = DEFAULT_MAX_QUEUE_LENGTH,cycle_length = DEFAULT_CYCLE_LENGTH)
    raise "Sensor required" if sensor.nil?
    raise "Sensor value required" if sensor_value.nil?

    @name = name
    @sensor = sensor
    @sensor_value = sensor_value
    @memory_queue = MemoryElements::MemoryQueue.new(max_queue_length)
    @cycle_length = cycle_length

    self
  end

  def current_sensor_value
    sensor.send(sensor_value)
  end

  def previous_sensor_value
    return nil if memory_queue.empty?
    memory_queue.last[0]
  end

  def previous_cycle_count
    return nil if memory_queue.empty?
    memory_queue.last[1]
  end

  def update_input_pattern
    if current_sensor_value == previous_sensor_value
      # increment the cycle count
      memory_queue[-1][1] += 1
    else
      memory_queue << [current_sensor_value,1]
    end
  end

  def current_input_pattern
    memory_queue
  end
end