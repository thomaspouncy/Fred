require 'ruby_nxt'

module NXTLogic
  def setup_nxt
    $DEBUG = false
    @nxt = NXTComm.new("/dev/tty.NXT-DevB")
    # @nxt.reset_motor_position(NXTComm::MOTOR_ALL)
  end

  def setup_ultrasonic_sensor
    @us = Commands::UltrasonicSensor.new(@nxt)
    @us.mode = :inches
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
end
