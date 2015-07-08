# define our own version of the spec task because rspec might not be available
# in the production environment, so we can't rely on RSpec::Core::RakeTask

namespace :spec do

  desc 'Run all tests'
  task(:all) { run_rspec! }

  desc 'Run all unit tests'
  task(:unit) { run_rspec! '~elasticsearch', '~vcr' }

  desc 'Run all integration tests'
  task :integration => [:elasticsearch]

  desc 'Run integration tests with ElasticSearch'
  task(:elasticsearch) { run_rspec! 'elasticsearch' }
end

task :spec => 'spec:all'
task :test => :spec

def run_rspec!(*tags)
  require 'rspec/core'

  args = tags.map { |tag| ['--tag', tag] }.flatten << './spec'
  code = RSpec::Core::Runner.run(args, $stderr, $stdout)

  exit(code) unless code == 0
end
