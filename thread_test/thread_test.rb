require "thread"

running_threads = []

Thread.abort_on_exception = false

puts "starting threads"

running_threads << Thread.new() do
  puts "a"
  sleep(1)
  puts "b"
  puts "c"
  sleep(1)
  puts "d"
end

running_threads << Thread.new() do
  puts "1"
  puts "2"
  raise "Some kind of exception"
end

begin
  puts "joining threads"
  running_threads.each {|thread| thread.join }
rescue => exc
  puts "shit went wrong: #{exc.inspect}"
  # running_threads.each {|thread| thread.kill }
  # raise exc
end

puts "we done, son"
