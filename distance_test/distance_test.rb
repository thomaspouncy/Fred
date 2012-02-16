require 'ruby_nxt'
require 'mongo'

# Constants

STOPPED_THRESHOLD				  = 0
TOP_SPEED_THRESHOLD				= 1
DEFAULT_STOPPING_DISTANCE = 10
DEFAULT_STOPPING_TIME			= 1.5
SLEEP_INTERVAL					  = 0.005

def setup_mongo
  @db = Mongo::Connection.new.db("fred")
  @col = @db.collection("distance_memory")
end

def get_distance
  @memory_queue << [@us.distance,Time.now.to_f]
  puts "Distance: #{@memory_queue.last[0]}in"
  puts "memory queue: #{@memory_queue.inspect}"

  return @memory_queue.last[0]
end

def update_speed_approximation
  total_distance = (@memory_queue.last[0] - @memory_queue.first[0]).abs
  total_time = (@memory_queue.last[1] - @memory_queue.first[1]).abs

  @estimated_self_speed = (total_distance.to_f / total_time)
  puts "estimated speed is now: #{@estimated_self_speed} in/s"

  return @estimated_self_speed
end

def update_stopping_distance
  speed = update_speed_approximation
  time_to_stop = @estimated_stopping_time

  # for now assuming a linear slow down process
  @estimated_stopping_distance = (speed*time_to_stop).to_f/2 + @adjusted_ultrasonic_distance
  puts "estimated stopping distance is now: #{@estimated_stopping_distance} in"

  return @estimated_stopping_distance
end

def we_appear_to_have_stopped
  return false if @memory_queue.length < 3
  (@memory_queue[-1][0] - @memory_queue[-2][0]).abs <= STOPPED_THRESHOLD ? true : false
end

def motors_reach_top_speed
  return false if @memory_queue.length < 3
  ((@memory_queue[-1][0] - @memory_queue[-2][0]).abs - (@memory_queue[-2][0] - @memory_queue[-3][0]).abs) <= TOP_SPEED_THRESHOLD ? true : false
end

def store_memory_in_long_term
  @col.insert({:_id=>Time.now.to_s,:memory=>@memory_queue})
end

def forget_everything
  store_memory_in_long_term
  @memory_queue.clear
end

def calculate_friction
  distances = []
  power_levels = [50,75,100]
  invalid_power_levels = []
  power_levels.each do |power_level|
    forget_everything
    start_motors(power_level)
    until motors_reach_top_speed
      sleep(SLEEP_INTERVAL)
      get_distance
    end
    start_distance = get_distance
    stop_motors
    until we_appear_to_have_stopped
      sleep(SLEEP_INTERVAL)
      get_distance
    end
    stop_distance = get_distance
    if stop_distance == start_distance
      puts "Power level #{power_level} was not high enough to overcome friction on this surface"
      invalid_power_levels << power_level
    else
      distances << (stop_distance - start_distance).abs
    end
  end

  puts "distances were: #{distances.inspect}"

  ratios = []
  (power_levels-invalid_power_levels).each_index {|x| ratios[x] = distances[x].to_f/power_levels[x] }
  puts "ratios are: #{ratios.inspect}"
  estimated_friction = ratios.inject(0) {|sum,ratio| sum+=ratio }.to_f/ratios.length
end

def drive_to_nearest_wall
  get_distance

  start_motors

  while get_distance > update_stopping_distance
    if we_appear_to_have_stopped
      stop_motors
      puts "We seem to have prematurely stopped. WTF"
      break
    end
    sleep(SLEEP_INTERVAL)
  end

  stop_motors

  puts "Got it!"
end

def start_motors(motor_power=100)
  ports = [:b,:c]
  mode = NXTComm::MOTORON | NXTComm::REGULATED
  reg_mode = NXTComm::REGULATION_MODE_MOTOR_SYNC
  run_state = NXTComm::MOTOR_RUN_STATE_RUNNING
  turn_ratio = 0
  tacho_limit = 0

  ports.each do |p|
    @nxt.set_output_state(
      NXTComm.const_get("MOTOR_#{p.to_s.upcase}"),
      motor_power,
      mode,
      reg_mode,
      turn_ratio,
      run_state,
      tacho_limit
    )
  end
end

def stop_motors
  @nxt.set_output_state(
    NXTComm::MOTOR_ALL,
    0,
    NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
    NXTComm::REGULATION_MODE_MOTOR_SPEED,
    0,
    NXTComm::MOTOR_RUN_STATE_RUNNING,
    0
  )
end

setup_mongo

$DEBUG = false

@nxt = NXTComm.new("/dev/tty.NXT-DevB")

@memory_queue = []
@estimated_stopping_distance = DEFAULT_STOPPING_DISTANCE
@estimated_stopping_time = DEFAULT_STOPPING_TIME
@estimated_self_speed = nil
@adjusted_ultrasonic_distance = 3

@nxt.reset_motor_position(NXTComm::MOTOR_ALL)

@us = Commands::UltrasonicSensor.new(@nxt)
@us.mode = :inches

# drive_to_nearest_wall
puts "Estimated friction was: #{calculate_friction}"

forget_everything
