# More info at https://github.com/guard/guard#readme


group :doc do
  guard 'yard' do
    watch(%r{app/.+\.rb})
    watch(%r{lib/.+\.rb})
    watch(%r{ext/.+\.c})
  end

  guard 'livereload' do
    watch(%r{doc/.+\.html})
  end
end

guard :shotgun do
  notification :off
  watch %r{^(app|lib|config)/.*\.rb}
  watch 'config.ru'
  watch 'init.rb'
end

scope plugin: :shotgun

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^spec/.+_helper.rb$})  { "spec" }
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
  watch(%r{^spec/fabricators/(.+)\.rb$}) { "spec" }
end
