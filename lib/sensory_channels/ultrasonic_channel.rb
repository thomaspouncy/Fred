require "sensory_channel"

class UltrasonicChannel < SensoryChannel
  def initialize(body)
    super(body,:ultrasonic)
  end
end
