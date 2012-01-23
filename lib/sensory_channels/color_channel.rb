require "sensory_channel"

class ColorChannel < SensoryChannel
  def initialize(body)
    super(body,:color)
  end
end
