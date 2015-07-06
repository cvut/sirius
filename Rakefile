require 'pliny/tasks'
# Add your rake tasks to lib/tasks!
Dir['./lib/tasks/*.rake'].each { |task| load task }

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

begin
  require 'rake-jekyll'

  namespace :raml do
    Rake::Jekyll::GitDeployTask.new(:publish) do |t|
      t.description = 'Generate API documentation from RAML and push changes to the remote repository.'
      t.committer = 'Travis'
      t.jekyll_build = ->(dest_dir) {
        Rake.sh "mkdir -p #{dest_dir}/docs"
        Rake.sh "raml2html docs/Sirius.raml > #{dest_dir}/docs/api-v1.html"
      }
    end
  end
rescue LoadError => e
  warn "#{e.path} is not available"
end

task :default => :spec


def run_rspec!(*tags)
  require 'rspec/core'

  args = tags.map { |tag| ['--tag', tag] }.flatten << './spec'
  status = RSpec::Core::Runner.run(args, $stderr, $stdout).to_i

  exit status if status != 0
end
