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
  watch %r{^(app|lib|config)/.*\.rb}
  watch 'config.ru'
  watch 'init.rb'
end

scope plugin: :shotgun
