# More info at https://github.com/guard/guard#readme

guard 'rubocop' do
  watch(/attributes\/.+\.rb$/)
  watch(/providers\/.+\.rb$/)
  watch(/recipes\/.+\.rb$/)
  watch(/resources\/.+\.rb$/)
  watch('metadata.rb')
end

guard :rspec, :cmd => 'chef exec /opt/chefdk/embedded/bin/rspec', :all_on_start => false, :notification => false do
  watch(/^libraries\/(.+)\.rb$/)
  watch(/^spec\/(.+)_spec\.rb$/)
  watch(/^(recipes)\/(.+)\.rb$/)   { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { 'spec' }
end
