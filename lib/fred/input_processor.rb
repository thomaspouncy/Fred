class InputProcessor
  attr_reader :name,
              :body

  def initialize(name,body)
    @name = name
    @body = body
  end

  def process_input(sense_name,input_pattern)
    puts "Processor '#{name}' processing input pattern '#{input_pattern.to_s}' for sense '#{sense_name}'"
  end
end

require "fred/input_processors/memory_processor"
