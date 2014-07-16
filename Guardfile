# A sample Guardfile
# More info at https://github.com/guard/guard#readme



scope groups: [:doc]

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
