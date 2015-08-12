This cookbook uses a variety of testing components:

- Unit tests: [ChefSpec](https://github.com/acrmp/chefspec)
- Integration tests: [Test Kitchen](https://github.com/opscode/test-kitchen)
- Chef Style lints: [Foodcritic](https://github.com/acrmp/foodcritic)
- Ruby Style lints: [Rubocop](https://github.com/bbatsov/rubocop)

Prerequisites
-------------
This cookbook was developed using the
[Chef Development Kit](https://downloads.chef.io/chef-dk/).

[Test Kitchen](http://kitchen.ci/) is used to instantiate VMs and run
recipes that come with the cookbook. In the case of library cookbooks
(those that ship resources instead of recipes), it used Berkshelf to
point at test cookbooks shipped under test/cookbooks that exercise the
resources.)

Test Kitchen can drive local VMs (VirtualBox, VMWare) via the Vagrant
plugin, or it can drive IaaS providers via plugins. (chef gem install kitchen-ec2)

This cookbook's `.kitchen.yml` comes pre-configured to use the Vagrant
plugin to drive Virtualbox. To use it, you must also have Vagrant and
VirtualBox installed:

- [Vagrant](https://vagrantup.com)
- [VirtualBox](https://virtualbox.org)

There is also a `.kitchen.cloud.yml`. That will drive various IaaS
providers. To use it, `export KITCHEN_YAML=.kitchen.cloud.yml`. You
will need to inspect it and manually install the necessary plugins.
It'll look something like this:

`chef gem install kitchen-sync`
`chef gem install kitchen-ec2`
`chef gem install kitchen-digitalocean`

Beyond that, you'll need to create accounts on the IaaS services and
manage the API and SSH secrets referred to.

This will pay off if you have a cookbook with a large amount of
suites. `kitchen converge -c` is a powerful thing.

Development
-----------
1. Clone the git repository from GitHub:

        $ git clone git@github.com:bflad/chef-COOKBOOK.git

2. Create a branch for your changes:

        $ git checkout -b my_bug_fix

3. Make any changes
4. Write tests to support those changes. It is highly recommended you write both unit and integration tests.
5. Run the tests:
    - `rspec`
    - `foodcritic .`
    - `rubocop`
    - `kitchen test`

6. Assuming the tests pass, open a Pull Request on GitHub
