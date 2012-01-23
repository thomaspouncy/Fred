class NXTBody < Body
  DEFAULT_TOUCH_PORT      = 1
  DEFAULT_ULTRASONIC_PORT = 4
  DEFAULT_COLOR_PORT      = 3

  attr_reader :nxt

  # Tell ruby-nxt to give us bluetooth details
  $DEBUG = true

  def initialize

  end

end
