$:.unshift File.dirname(__FILE__)

require 'thread'
require 'mongo_logic'
require 'nxt_logic'
require 'memory_logic'
require 'calculation_logic'

class SensorLoop
  include MongoLogic
  include NXTLogic
  include MemoryLogic
  include CalculationLogic

  MOTOR_POWER          = 75
  STOPPING_DISTANCE    = 3.33
  DESIRED_END_DISTANCE = 3
  SLEEP_INTERVAL       = 0.5

  attr_accessor :running_threads

  def running_threads
    @running_threads ||= []
  end

  attr_reader :base_thread

  def get_ultrasonic_sensor_value
    @us.distance
  end

  def get_motor_rotation_value
    @nxt.get_output_state(NXTComm.const_get("MOTOR_#{ports.first.to_s.upcase}"))[:tacho_count]
  end

  def check_for_stop(frozen_memory_queue)
    puts "checking for stop and frozen_memory_queue is: #{frozen_memory_queue.inspect}"
    begin
      if frozen_memory_queue.length == 1
        puts "Looks like our first memory. Start the motors!"
        start_motors(MOTOR_POWER)

        running_threads.delete(Thread.current)
        Thread.current.kill
        return
      else
        if (frozen_memory_queue[-1][:rotation] != frozen_memory_queue[-2][:rotation])
          puts "motors still appear to be turning. #{frozen_memory_queue.inspect}"
          if (frozen_memory_queue[-1][:distance] == frozen_memory_queue[-2][:distance])
            puts "we appear to have stopped prematurely"

            kill_processes
          end
        else
          puts "motors dont seem to have started yet. #{frozen_memory_queue.inspect}"

          running_threads.delete(Thread.current)
          Thread.current.kill
          return
        end
      end

      return frozen_memory_queue
    rescue Exception => exc
      puts "got exception: #{exc.inspect} when checking for stop"
      kill_processes
    end
  end

  def calculate_predicted_distance(frozen_memory_queue)
    puts "calculating distance and frozen_memory_queue is: #{frozen_memory_queue.inspect}"
    begin
      recent_speeds = []
      frozen_memory_queue.each_index do |x|
        unless x == 0
          distance = (frozen_memory_queue[x][:distance]-frozen_memory_queue[x-1][:distance]).abs
          time = (frozen_memory_queue[x][:time]-frozen_memory_queue[x-1][:time]).abs
          recent_speeds << (distance.to_f / time)
        end
      end

      puts "recent speeds are: #{recent_speeds.inspect}"

      average_cycle_lengths = []
      frozen_memory_queue.each_index do |x|
        unless x == 0
          average_cycle_lengths << (frozen_memory_queue[x][:time]-frozen_memory_queue[x-1][:time]).abs
        end
      end

      puts "average cycle lengths are: #{average_cycle_lengths.inspect}"

      average_cycle_time = average_cycle_lengths.inject(0) {|sum,current| sum+current }.to_f / average_cycle_lengths.length

      puts "average cycle time is #{average_cycle_time}"

      predicted_distance = frozen_memory_queue.last[:distance] - (recent_speeds.last * average_cycle_time)

      puts "next predicted_distance = #{predicted_distance}"

      return predicted_distance
    rescue Exception => exc
      puts "got exception: #{exc.inspect} when calculating distance"
      kill_processes
    end
  end

  def compare_distance_to_goals(predicted_distance)
    puts "comparing distance and predicted is: #{predicted_distance.inspect}"
    begin
      if predicted_distance < STOPPING_DISTANCE + DESIRED_END_DISTANCE
        puts "reached distance. stopping motors"
        stop_motors

        kill_processes
        return
      else
        puts "still some distance to go"
      end
    rescue Exception => exc
      puts "got exception: #{exc.inspect} when comparing to goals"
      kill_processes
    end
  end

  def kill_processes
    running_threads.each do |thr|
      thr.kill
    end
  end

  def pass_sensor_values_to_processors
    method_chain = [
      :check_for_stop,
      :calculate_predicted_distance,
      :compare_distance_to_goals
    ]
    process_proc = lambda do
      method_chain.inject(memory_queue) do |prev_return_value,current_method|
        send(current_method,prev_return_value)
      end

      running_threads.delete(Thread.current)
      Thread.current.kill
    end
    puts "Adding new thread with memory queue: #{memory_queue} and chain: #{method_chain.inspect}. Thread count is: #{running_threads.count}"

    running_threads << Thread.new(&process_proc)
  end

  def run()
    begin
      @base_thread = Thread.current
      Thread.abort_on_exception = true

      # setup_mongo("fred","sensor_loop_memory")
      puts "running sensor loop"
      setup_nxt
      setup_ultrasonic_sensor
      reset_motors
      puts "starting rotation is: #{get_motor_rotation_value}"
      puts "setup complete"

      cycle_count = 0

      puts "starting loop"
      running_threads << Thread.new() do
        loop do
          current_sensory_inputs = {
            :time => Time.now.to_i,
            :distance => get_ultrasonic_sensor_value,
            :rotation => get_motor_rotation_value
          }

          memory_queue << current_sensory_inputs

          puts "start time was: #{current_sensory_inputs[:time]}"
          puts "distance is: #{current_sensory_inputs[:distance]}"
          puts "rotation is: #{current_sensory_inputs[:rotation]}"

          pass_sensor_values_to_processors

          sleep(SLEEP_INTERVAL)
        end
      end

      running_threads.first.join

      puts "We have stopped moving. All threads killed"
      stop_motors
      @nxt.close
    rescue Exception => exc
      unless @nxt.nil?
        stop_motors
        kill_processes
        @nxt.close
      end
      raise exc
    end
  end
end

SensorLoop.new().run

