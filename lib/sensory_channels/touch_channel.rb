require "sensory_channel"

class TouchChannel < SensoryChannel
  def initialize(body)
    super(body,:touch)
  end
end
