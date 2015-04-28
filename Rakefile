require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

file 'lib/rubic/parser.rb' => 'lib/rubic/parser.y' do |t|
  sh "bundle exec racc -o #{t.name} #{t.prerequisites.first}"
end

task :test => 'lib/rubic/parser.rb'
task :default => :test
