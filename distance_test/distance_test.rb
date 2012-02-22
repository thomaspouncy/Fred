$:.unshift File.dirname(__FILE__)

require 'mongo_logic'
require 'nxt_logic'
require 'memory_logic'
require 'calculation_logic'

class DistanceTest
  include MongoLogic
  include NXTLogic
  include MemoryLogic
  include CalculationLogic

  # Constants

  STOPPED_THRESHOLD				  = 0
  TOP_SPEED_THRESHOLD				= 1
  DEFAULT_STOPPING_DISTANCE = 10
  DEFAULT_STOPPING_TIME			= 1.5
  SLEEP_INTERVAL					  = 0.001

  def get_distance
    latest_distance = {:distance=>@us.distance,:time=>Time.now.to_f}
    unless memory_queue.empty?
      latest_distance[:speed] = approximate_current_speed(latest_distance)
    end
    memory_queue << latest_distance
    puts "Distance: #{memory_queue.last[:distance]}in"
    puts "memory queue: #{memory_queue.inspect}"

    return memory_queue.last[:distance]
  end

  def we_appear_to_have_stopped
    return false if memory_queue.length < 3
    (memory_queue[-1][:distance] - memory_queue[-2][:distance]).abs <= STOPPED_THRESHOLD ? true : false
  end

  def motors_reach_top_speed
    return false if memory_queue.length < 3
    ((memory_queue[-1][:distance] - memory_queue[-2][:distance]).abs - (memory_queue[-2][:distance] - memory_queue[-3][:distance]).abs) <= TOP_SPEED_THRESHOLD ? true : false
  end

  def calibrate_ultrasonic_sensor
    start_memory_event("ultrasonic_calibration_test")

    clear_short_term_memory

    start_motors

    until we_appear_to_have_stopped
      sleep(SLEEP_INTERVAL)
      get_distance
    end

    stop_motors

    sensor_distance_error = get_distance

    clear_short_term_memory

    remember_event_information({:sensor_distance_error => sensor_distance_error})
    puts "calculated distance error is #{sensor_distance_error}"

    end_memory_event("ultrasonic_calibration_test")

    sensor_distance_error
  end

  def drive_to_nearest_wall
    @desired_end_distance = 3

    start_motors(@motor_power)

    while predicted_next_distance > (@estimated_stopping_distance + @desired_end_distance)
      if we_appear_to_have_stopped
        stop_motors
        puts "We seem to have prematurely stopped"
        break
      end
      sleep(SLEEP_INTERVAL)
    end

    stop_motors

    puts "Actual distance: #{get_distance}. Desired distance: #{@desired_end_distance}"
  end

  def run
    begin
      setup_mongo
      setup_nxt
      setup_ultrasonic_sensor
      clear_short_term_memory

      if we_remember_the_event?("ultrasonic_calibration_test")
        puts "memory of sensor calibration found"
        @sensor_distance_error = fetch_info_from_memory_of_event("sensor_distance_error","ultrasonic_calibration_test")

        if we_remember_the_event?("friction_test")
          puts "friction memory found, driving to wall"
          estimated_friction = fetch_info_from_memory_of_event("estimated_friction","friction_test")
          @motor_power = 100
          @estimated_stopping_distance = estimated_friction * @motor_power
          puts "estimated_stopping_distance: #{@estimated_stopping_distance}"
          drive_to_nearest_wall
        else
          puts "no memories of friction; calculating friction"
          calculate_friction
        end
      else
        puts "needs to calibrate ultrasonic sensor"
        calibrate_ultrasonic_sensor
      end

      @nxt.close
    rescue Exception => exc
      puts "Caught exception: #{exc.inspect}"
      unless @nxt.nil?
        stop_motors
        @nxt.close
      end
    end
  end
end

DistanceTest.new().run
