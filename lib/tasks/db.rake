namespace :db do
  Rake::Task['db:seed'].enhance ['sirius:env'] # set up load path for models
end
