require "memory_elements/memory_queue"

class SensoryChannel
  MAX_QUEUE_LENGTH 			8
  CYCLE_LENGTH					1

  attr_reader :memory_queue, 						# An array of prior values for pattern matching. Each entry is formatted [value,number_of_cycles_value_has_been_recorded]
              :reflexes, 								# Matches input patterns to actions for extremely high priority responses
              :central_nervous_system,	# Matches input patterns to actions for standard level responses
              :sensor,
              :sensor_value


  def initialize(body,sense_name)
    raise "Invalid body: #{body.inspect}" unless body.respond_to(:reflexes) && body.respond_to(:central_nervous_system)
    raise "Sense name required" if sense_name.blank?

    @memory_queue = MemoryQueue.new(MAX_QUEUE_LENGTH)
    @reflexes = body.reflexes
    @central_nervous_system = body.central_nervous_system

    @sensor = body.senses[sense_name.to_sym][:sensor]
    @sensor_value = body.senses[sense_name.to_sym][:sensor_value]

    self
  end

  def current_sensor_value
    sensor.send(sensor.value)
  end

  def previous_sensor_value
    return nil if memory_queue.empty?
    memory_queue.last[0]
  end

  def previous_cycle_count
    return nil if memory_queue.empty?
    memory_queue.last[1]
  end

  def read_sensor_value
    if current_sensor_value == previous_sensor_value
      # increment the cycle count
      memory_queue[-1][1] += 1
    else
      memory_queue << [current_sensor_value,1]
    end
  end

  def send_to_reflexes
    reflexes.process_input(memory_queue)
  end

  def send_to_cns
    central_nervous_system.process_input(memory_queue)
  end

  def sensory_cycle
    read_sensor_value

    send_to_reflexes
    send_to_cns

    sleep(CYCLE_LENGTH)
  end
end