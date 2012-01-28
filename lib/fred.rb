$:.unshift File.dirname(__FILE__)

require 'fred/memory_elements'
require 'fred/sensory_channel'
require 'fred/decision_maker'
require 'fred/body'

def come_to_life
  body = NXTBody.new()

  body.initialize_senses

  sleep(10)

  body.die
end
