class MemoryProcessor < InputProcessor
  def initialize(body)
    super("Memory Processor",body)
  end

  def process_input(sense_name,input_pattern)
    puts "Processing memory for sense '#{sense_name}' with input pattern #{input_pattern}"
  end

  def process_output(limb_name,input_pattern,peformed_output)
    puts "Processing memory for limb '#{limb_name}'. Performed output #{performed_output} after input #{input_pattern}"
  end
end
