require "thread"

class Body
  LISTENER_CYCLE_LENGTH   = 1

  attr_reader :goal_processor,
              :reflex_processor,
              :memory_processor,
              :sensory_channels,
              # :limbs,
              # :reflex_memory,
              # :short_term_memory,
              # :pleasure_inputs,
              # :pain_inputs,
              :mutex,
              :condition_variables

  attr_accessor :running_threads

  def initialize(sensory_channels,goal_processor = InputProcessor.new("Goal Processor",self),reflex_processor = InputProcessor.new("Reflex Processor",self), memory_processor = MemoryProcessor.new(self))
    @sensory_channels = sensory_channels
    # @limbs = limbs
    @goal_processor = goal_processor
    @reflex_processor = reflex_processor
    @memory_processor = memory_processor
    # @reflex_memory = MemoryElements::MemoryHash.new()
    # @short_term_memory = MemoryElements::MemoryHash.new()
    self.running_threads = []
    @mutex = Mutex.new()
    @condition_variables = {
      :reflex_memory_available => ConditionVariable.new(),
      :short_term_memory_available => ConditionVariable.new()
    }

    self
  end

  def wake_up
    initialize_console_listener
    initialize_senses

    begin
      running_threads.each {|thread| thread.join }
    rescue => exc
      body.die
      raise exc
    end
  end

  def senses_initialized?
    @senses_initialized == true
  end

  def initialize_senses
    raise "Senses already initialized" if senses_initialized?

    new_threads = []

    sensory_channels.each do |key,sensory_channel|
      new_threads << Thread.new(self,sensory_channel) do |body,channel|
        puts "Initializing channel '#{channel.name}'"
        loop do
          # check for term signal

          channel.update_input_pattern

          input_pattern = channel.current_input_pattern

          # send to reflexes and goals to decide output based on current st mem/body mem
          # on limb action add input_pattern/output_pattern to memory
          # when favorable input is reached, check recent input/output pairings in st mem
          # link weight based on number of times this link has been made
          # use strength of these links to decide actions in goal processor
          # if link strength reaches certain point, add to reflex memory

          body.reflex_processor.process_input(channel.name,input_pattern)

          body.goal_processor.process_input(channel.name,input_pattern)

          body.memory_processor.process_input(channel.name, input_pattern)

          sleep(channel.cycle_length)
        end
      end
    end

    # condition_variables[:reflex_memory_available].signal
    # condition_variables[:short_term_memory_available].signal

    self.running_threads += new_threads

    @senses_initialized = true
  end

  def die?
    begin
      while c = STDIN.read_nonblock(1)
        return true if c == 'die'
      end
      false
    rescue Errno::EINTR
      puts "Well, your device seems a little slow..."
      false
    rescue Errno::EAGAIN
      puts "Nothing to be read..."
      false
    rescue EOFError
      # (user hit CTRL-D)
      puts "Who hit CTRL-D, really?"
      true
    end
  end

  def listener_initialized?
    @listener_initialized == true
  end

  def initialize_console_listener
    raise "Console listener already initialized" if listener_initialized?

    self.running_threads << Thread.new(self)  do |body|
      loop do
        body.die if die?
        sleep(LISTENER_CYCLE_LENGTH)
      end
    end

    @listener_initialized = true
  end

  def die
    puts "killing body"
    running_threads.each {|thread| thread.kill }
  end
end

require 'fred/body_types/nxt_body'
