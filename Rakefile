require 'pliny/tasks'
# Add your rake tasks to lib/tasks!
Dir['./lib/tasks/*.rake'].each { |task| load task }

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



