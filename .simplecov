if ENV['COVERAGE'] || ENV['CI']
  require 'codeclimate-test-reporter'
  require 'coveralls'

  formatters = [SimpleCov::Formatter::HTMLFormatter]

  formatters << Coveralls::SimpleCov::Formatter if ENV['COVERALLS_REPO_TOKEN']
  formatters << CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  SimpleCov.start 'rails' do
    add_group 'Models', 'app/models'
    add_group 'Interactors', 'app/interactors'
    add_group 'Roles', 'app/roles'
    add_group 'Sirius', 'lib/sirius/'
    add_group 'API', '(app/api|lib/sirius_api)'
  end
end
