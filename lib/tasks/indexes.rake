namespace :indexes do

  def indexes
    [ MultiSearchIndex ]
  end

  task :env => 'sirius:env' do
    require 'chewy/rake_helper'
    require 'models/multi_search_index'

    Chewy::RakeHelper.subscribe_task_stats!
  end

  desc 'Destroy all indexes'
  task :nuke => :env do
    indexes.each do |index|
      puts "Deleting index #{index.index_name}"
      index.delete
    end
  end

  desc 'Create indexes'
  task :create => :env do
    indexes.each do |index|
      puts "Creating index #{index.index_name}"
      fail "Index #{index.index_name} already exists." if index.exists?
      index.create!
    end
  end

  desc 'Update data in indexes'
  task :update => :env do
    indexes.each do |index|
      puts "Updating index #{index.index_name}"
      fail "Index #{index.index_name} does not exist." unless index.exists?
      index.import
    end
  end

  desc 'Reset indexes, i.e. purge and import data'
  task :reset => :env do
    indexes.each do |index|
      puts "Resetting index #{index.index_name}"
      index.reset! (Time.now.to_f * 1000).round
    end
  end
end
