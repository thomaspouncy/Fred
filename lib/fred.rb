require 'sensory_channel'
require 'decision_makers'
require 'bodies'

body = NXTBody.new()

body.initialize_senses

sleep(10)

body.kill
