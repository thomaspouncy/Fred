$:.unshift File.dirname(__FILE__)

require 'fred/memory_elements'
require 'fred/sensory_channel'
require 'fred/input_processor'
require 'fred/body'

def wake_up_body
  body = NXTBody.new()

  body.wake_up
end
