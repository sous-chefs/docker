# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# rubocop:disable RegexpLiteral
guard 'kitchen' do
  watch(%r{test/.+})
  watch(%r{^recipes/(.+)\.rb$})
  watch(%r{^attributes/(.+)\.rb$})
  watch(%r{^files/(.+)})
  watch(%r{^templates/(.+)})
  watch(%r{^providers/(.+)\.rb})
  watch(%r{^resources/(.+)\.rb})
end
# rubocop:enable RegexpLiteral
