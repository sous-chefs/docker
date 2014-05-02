This cookbook uses a variety of testing components:

- Unit tests: [ChefSpec](https://github.com/acrmp/chefspec)
- Integration tests: [Test Kitchen](https://github.com/opscode/test-kitchen)
- Chef Style lints: [Foodcritic](https://github.com/acrmp/foodcritic)
- Ruby Style lints: [Rubocop](https://github.com/bbatsov/rubocop)

Prerequisites
-------------
To develop on this cookbook, you must have a sane Ruby 1.9+ environment. Given the nature of this installation process (and it's variance across multiple operating systems), we will leave this installation process to the user.

You must also have `bundler` installed:

    $ gem install bundler

You must also have Vagrant and VirtualBox installed:

- [Vagrant](https://vagrantup.com)
- [VirtualBox](https://virtualbox.org)

Once installed, you must install the `vagrant-berkshelf` plugin:

    $ vagrant plugin install vagrant-berkshelf

Development
-----------
1. Clone the git repository from GitHub:

        $ git clone git@github.com:bflad/chef-COOKBOOK.git

2. Install the dependencies using bundler:

        $ bundle install

3. Create a branch for your changes:

        $ git checkout -b my_bug_fix

4. Make any changes
5. Write tests to support those changes. It is highly recommended you write both unit and integration tests.
6. Run the tests:
    - `bundle exec rspec`
    - `bundle exec foodcritic .`
    - `bundle exec rubocop`
    - `bundle exec kitchen test`

7. Assuming the tests pass, open a Pull Request on GitHub

Instance                        Status          Reason
package-native-centos-65        pass            
package-native-debian-72        pass
package-native-debian-74        pass
package-native-fedora-19        pass
package-native-fedora-20        pass
package-native-ubuntu-1204      pass
package-native-ubuntu-1304      pass
package-native-ubuntu-1310      pass
package-lxc-centos-65           pass
package-lxc-debian-72           pass
package-lxc-debian-74           pass
package-lxc-fedora-19           fail            fedora doesn’t like lxc
package-lxc-fedora-20           fail            fedora doesn’t like lxc
package-lxc-ubuntu-1204         pass
package-lxc-ubuntu-1304         pass
package-lxc-ubuntu-1310         pass
binary-native-centos-65         fail            bad kernel 2.6.32
binary-native-debian-72         pass
binary-native-debian-74         pass
binary-native-fedora-19         pass
binary-native-fedora-20         pass
binary-native-ubuntu-1204       pass
binary-native-ubuntu-1304       pass
binary-native-ubuntu-1310       pass
binary-lxc-centos-65            (skipped)       bad kernel 
binary-lxc-debian-72            unstable
binary-lxc-debian-74            pass
binary-lxc-fedora-19            fail
binary-lxc-fedora-20            fail
binary-lxc-ubuntu-1204          pass
binary-lxc-ubuntu-1304          pass 
binary-lxc-ubuntu-1310          pass
