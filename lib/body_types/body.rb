require "thread"

class Body
  attr_reader :central_nervous_system,
              :reflexes,
              :sensory_channels,
              :running_threads,
              :mutex,
              :conditional_variables

  def initialize(sensory_channels,cns = DecisionMaker.new(),reflexes = DecisionMaker.new())
    @sensory_channels = sensory_channels
    @central_nervous_system = cns
    @reflexes = reflexes
    @running_threads = []
    @mutex = Mutex.new()
    @conditional_variables = {
      :reflexes_available => ConditionalVariable.new(),
      :cns_available => ConditionalVariable.new()
    }

    self
  end

  def senses_initialized?
    @senses_initialized
  end

  def initialize_senses
    raise "Senses already initialized" if senses_initialized?

    sensory_channels.each do |sensory_channel|
      new_threads << Thread.new(self,sensory_channel) do |body,channel|
        puts "Initializing channel '#{channel.name}'"
        loop do
          input_pattern = channel.current_input_pattern

          mutex.synchronize {
            conditional_variables[:reflexes_available].wait(mutex)
            body.send_to_reflexes(channel.name,input_pattern)
            conditional_variables[:reflexes_available].signal
          }
          mutex.synchronize {
            conditional_variables[:cns_available].wait(mutex)
            body.send_to_cns(channel.name,input_pattern)
            conditional_variables[:cns_available].signal
          }

          sleep(channel.cycle_length)
        end
      end
    end

    new_threads.each {|thread| thread.join }
    running_threads.push(new_threads)

    @senses_initialized = true
  end

  def send_to_reflexes(sense_name,input_pattern)
    reflexes.process_input_pattern(sense_name,input_pattern)
  end

  def send_to_cns(sense_name,input_pattern)
    central_nervous_system.process_input_pattern(sense_name,input_pattern)
  end

  def kill
    puts "killing body"
    running_threads.each {|thread| thread.stop }
  end
end
