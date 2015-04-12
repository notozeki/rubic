require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

namespace :racc do
  desc 'Compile syntax file'
  task :compile do
    src = 'lib/rubic/parser.y'
    dst = 'lib/rubic/parser.rb'
    sh "bundle exec racc -o #{dst} #{src}"
  end
end

task :test => 'racc:compile'
task :default => 'racc:compile'
