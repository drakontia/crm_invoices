require 'rake'
require 'rspec/core/rake_task'
desc 'Default: run specs.'

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--colour --format progress']
  t.pattern = 'spec/**/*_spec.rb'
end
