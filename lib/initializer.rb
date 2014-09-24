require 'pliny/utils'

module Initializer
  def self.run
    require_config
    require_initializers
    add_paths
  end

  def self.require_config
    require_relative "../config/config"
  end

  def self.add_paths
    add_load_paths! Config.root
    add_load_paths! %w(
      lib
      app
      app/api
      app/models
      app/interactors
      app/helpers
      app/representers
      app/roles
    )
  end

  def self.require_initializers
    Pliny::Utils.require_glob("#{Config.root}/config/initializers/*.rb")
  end

  def self.require!(globs)
    globs = [globs] unless globs.is_a?(Array)
    globs.each do |f|
      Pliny::Utils.require_glob("#{Config.root}/#{f}.rb")
    end
  end

  def self.add_load_paths!(paths)
    paths = Array(paths)
    paths.each do |path|
      $LOAD_PATH << File.expand_path(path, Config.root)
    end
  end
end

Initializer.run
