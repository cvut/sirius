namespace :db do
  namespace :enable do
    desc "enable hstore extension"
    task :hstore => :environment do
      ::Sequel::Model.db.run 'CREATE EXTENSION IF NOT EXISTS hstore;'
    end
  end

  Rake::Task['db:schema:load'].enhance ['db:enable:hstore']
end
