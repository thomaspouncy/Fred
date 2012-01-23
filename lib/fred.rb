require 'ruby-nxt'
require 'sensory_channels'
require 'decision_makers'
require 'bodies'

DEFAULT_BODY_TYPE   = BodyType::NXT

nxt = NXTComm.new("/dev/tty.NXT-DevB")

begin
  light_sensor = Commands::LightSensor.new(nxt)

  sleep(1)


  puts "Using illuminated mode"
  light_sensor.generate_light = true

  sleep(1)

  puts "Using ambient mode"
  light_sensor.generate_light = false

  sleep(1)

  puts "light level is #{light_sensor.intensity}"
rescue => exc
  puts "returned exception #{exc.inspect}"
end

nxt.close
