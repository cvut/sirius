if ENV['COVERAGE'] || ENV['CI']
  require 'codeclimate-test-reporter'
  require 'coveralls'

  formatters = [SimpleCov::Formatter::HTMLFormatter]

  formatters << Coveralls::SimpleCov::Formatter if ENV['COVERALLS_REPO_TOKEN']
  formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  SimpleCov.start 'rails'
end
