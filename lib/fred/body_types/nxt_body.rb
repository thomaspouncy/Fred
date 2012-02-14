require 'ruby_nxt'

class NXTBody < Body
  DEFAULT_TOUCH_PORT      = 1
  DEFAULT_COLOR_PORT      = 3
  DEFAULT_ULTRASONIC_PORT = 4

  attr_reader :nxt

  # Tell ruby-nxt to give us bluetooth details
  $DEBUG = true

  def initialize(touch_port = DEFAULT_TOUCH_PORT,color_port = DEFAULT_COLOR_PORT,ultrasonic_port = DEFAULT_ULTRASONIC_PORT)
    @nxt = NXTComm.new("/dev/tty.NXT-DevB")

    sensory_channels = {
      :touch => SensoryChannel.new("touch",Commands::TouchSensor.new(nxt,touch_port),:raw_value),
      :color => SensoryChannel.new("color",Commands::ColorSensor.new(nxt,color_port),:current_color),
      :ultrasonic => SensoryChannel.new("ultrasonic",Commands::UltrasonicSensor.new(nxt,ultrasonic_port),:distance)
    }

    super(sensory_channels)
  end

  def die
    unless sensory_channels[:color].nil?
      sensory_channels[:color].sensor.light_sensor
    end

    nxt.close

    super
  end
end
