require 'rake/testtask'

task :default => [:test]

desc "Run basic tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
}
