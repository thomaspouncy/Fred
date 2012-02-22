$:.unshift File.dirname(__FILE__)

require 'mongo_logic'
require 'nxt_logic'
require 'memory_logic'
require 'calculation_logic'

class SensorLoop
  include MongoLogic
  include NXTLogic
  include MemoryLogic
  include CalculationLogic

  MOTOR_POWER          = 100
  STOPPING_DISTANCE    = 3.33
  DESIRED_END_DISTANCE = 3

  def get_ultrasonic_sensor_value
    @us.distance
  end

  def get_motor_rotation_value
    @nxt.get_output_state(NXTComm.const_get("MOTOR_#{ports.first.to_s.upcase}"))[:tacho_count]
  end

  def run()
    begin
      # setup_mongo("fred","sensor_loop_memory")
      puts "running sensor loop"
      setup_nxt
      setup_ultrasonic_sensor
      reset_motors
      puts "starting rotation is: #{get_motor_rotation_value}"
      puts "setup complete"

      cycle_count = 0

      puts "starting loop"
      loop do
        cycle_count += 1
        cycle_start_time = Time.now
        distance = get_ultrasonic_sensor_value
        rotation = get_motor_rotation_value

        puts "start time was: #{cycle_start_time.to_i}"
        puts "distance is: #{distance}"
        puts "rotation is: #{rotation}"

        if cycle_count == 1
          puts "starting motors"
          start_motors(MOTOR_POWER)
        end

        if distance <= STOPPING_DISTANCE + DESIRED_END_DISTANCE
          puts "reached distance"
          break
        end

        cycle_end_time = Time.now
        puts "end time was: #{cycle_end_time.to_i}"
      end

      puts "Goal reached"
      stop_motors
      @nxt.close
    rescue Exception => exc
      unless @nxt.nil?
        stop_motors
        @nxt.close
      end
      raise exc
    end
  end
end

SensorLoop.new().run

