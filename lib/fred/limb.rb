class Limb
  DEFAULT_MAX_QUEUE_LENGTH 	  = 8
  DEFAULT_CYCLE_LENGTH				= 0.25

  attr_reader :name,
              :motor,
              :valid_movements,
              :position_value,
              :memory_queue,
              :cycle_length

  def initialize(name,motor,valid_movements,position_value,max_queue_length = DEFAULT_MAX_QUEUE_LENGTH,cycle_length = DEFAULT_CYCLE_LENGTH)
    raise "Motor required" if motor.nil?
    raise "Valid movements array required" if valid_movements.nil? || !valid_movements.is_a?(Array)

    @name = name
    @motor = motor
    @valid_movements = valid_movements
    @position_value = position_value
    @memory_queue = MemoryElements::MemoryQueue.new(max_queue_length)
    @cycle_length = cycle_length

    self
  end

  def current_position
    motor.send(position_value)
  end

  def do_action(action_name)
    raise "Invalid action" unless valid_movements.include?(action_name.to_sym)

    movement_translator.translate_and_perform(motor,action_name)

    memory_queue << action_name
  end
end