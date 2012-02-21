module CalculationLogic
  def approximate_current_speed(latest_distance)
    prev_distance = @memory_queue.last
    current_speed = (latest_distance[:distance]-prev_distance[:distance]).abs.to_f / (latest_distance[:time] - prev_distance[:time]).abs
  end

  def predicted_next_distance
    return get_distance if @memory_queue.empty? || @memory_queue.last[:speed].nil?

    get_distance - (@memory_queue.last[:speed]*(Time.now.to_f - @memory_queue[-2][:time].to_f).abs)
  end

  # def update_speed_approximation
    # total_distance = (@memory_queue.last[0] - @memory_queue.first[0]).abs
    # total_time = (@memory_queue.last[1] - @memory_queue.first[1]).abs
  #
    # @estimated_self_speed = (total_distance.to_f / total_time)
    # puts "estimated speed is now: #{@estimated_self_speed} in/s"
  #
    # return @estimated_self_speed
  # end

  # def update_stopping_distance
    # speed = update_speed_approximation
    # time_to_stop = @estimated_stopping_time
  #
    # # for now assuming a linear slow down process
    # @estimated_stopping_distance = (speed*time_to_stop).to_f/2 + @adjusted_ultrasonic_distance
    # puts "estimated stopping distance is now: #{@estimated_stopping_distance} in"
  #
    # return @estimated_stopping_distance
  # end

  def calculate_friction
    start_memory_event("friction_test")

    distances = []
    power_levels = [50,75,100]
    invalid_power_levels = []
    ratios = []

    power_levels.each do |power_level|
      start_memory_event_section("power_level_#{power_level}")

      clear_short_term_memory

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

        remember_event_information({:invalid_power_levels => invalid_power_levels})
      else
        distances << (stop_distance - start_distance).abs
        ratios << distances.last.to_f/power_level

        remember_event_section_information({:distance=>distances.last,:ratio=>ratios.last})
      end

      end_memory_event_section("power_level_#{power_level}")
    end

    puts "distances were: #{distances.inspect}"

    puts "ratios are: #{ratios.inspect}"
    estimated_friction = ratios.inject(0) {|sum,ratio| sum+=ratio }.to_f/ratios.length

    remember_event_information({:estimated_friction => estimated_friction })

    end_memory_event("friction_test")

    estimated_friction
  end
end
