require 'serverspec'

set :backend, :exec
puts "os: #{os}"

describe command('echo "hi" | nc localhost 1234') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/hi/) }
end
