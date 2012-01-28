require "thread"

class Body
  attr_reader :central_nervous_system,
              :reflexes,
              :sensory_channels,
              :mutex,
              :condition_variables

  attr_accessor :running_threads

  def initialize(sensory_channels,cns = DecisionMaker.new(),reflexes = DecisionMaker.new())
    @sensory_channels = sensory_channels
    @central_nervous_system = cns
    @reflexes = reflexes
    self.running_threads = []
    @mutex = Mutex.new()
    @condition_variables = {
      :reflexes_available => ConditionVariable.new(),
      :cns_available => ConditionVariable.new()
    }

    self
  end

  def senses_initialized?
    @senses_initialized == true
  end

  def initialize_senses
    raise "Senses already initialized" if senses_initialized?

    new_threads = []

    sensory_channels.each do |sensory_channel|
      new_threads << Thread.new(self,sensory_channel) do |body,channel|
        puts "Initializing channel '#{channel.name}'"
        loop do
          channel.update_input_pattern

          input_pattern = channel.current_input_pattern

          body.send_to_reflexes(channel.name,input_pattern)
          body.send_to_cns(channel.name,input_pattern)

          #sleep(channel.cycle_length)
        end
      end
    end

    self.running_threads += new_threads

    @senses_initialized = true
  end

  def send_to_reflexes(sense_name,input_pattern)
    reflexes.process_input_pattern(sense_name,input_pattern)
  end

  def send_to_cns(sense_name,input_pattern)
    central_nervous_system.process_input_pattern(sense_name,input_pattern)
  end

  def die
    puts "killing body"
    running_threads.each {|thread| thread.kill }
  end
end

# Dir["fred/body_types/*.rb"].each {|file| require file }

