#
# Copyright:: Copyright (c) 2015-2016 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rake'

SOURCE = File.join(File.dirname(__FILE__), '..', 'MAINTAINERS.toml')
TARGET = File.join(File.dirname(__FILE__), '..', 'MAINTAINERS.md')

begin
  require 'tomlrb'
  task default: 'maintainers:generate'

  namespace :maintainers do
    desc 'Generate MarkDown version of MAINTAINERS file'
    task :generate do
      @toml = Tomlrb.load_file SOURCE
      out = "<!-- This is a generated file. Please do not edit directly -->\n\n"

      out << preamble
      out << project_lieutenant
      out << all_maintainers

      File.open(TARGET, 'w') do |fn|
        fn.write out
      end
    end
  end

rescue LoadError
  STDERR.puts "\n*** TomlRb not available. Skipping the Maintainers Rake task\n\n"
end

private

def preamble
  <<-EOL
# #{@toml['Preamble']['title']}
#{@toml['Preamble']['text']}
EOL
end

def project_lieutenant
  <<-EOL
# #{@toml['Org']['Components']['Core']['title']}
#{github_link(@toml['Org']['Components']['Core']['lieutenant'])}

EOL
end

def all_maintainers
  text = "# Maintainers\n"
  @toml['Org']['Components']['Core']['maintainers'].each do |m|
    text << "#{github_link(m)}\n"
  end
  text
end

def github_link(person)
  name = @toml['people'][person]['name']
  github = @toml['people'][person]['github']
  "* [#{name}](https://github.com/#{github})"
end
