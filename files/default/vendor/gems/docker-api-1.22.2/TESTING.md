# Prerequisites
To develop on this gem, you must the following installed:
* a sane Ruby 1.9+ environment with `bundler`
```shell
$ gem install bundler
```
* Docker v1.3.1 or greater



# Getting Started
1. Clone the git repository from Github:
```shell
$ git clone git@github.com:swipely/docker-api.git
```
2. Install the dependencies using Bundler
```shell
$ bundle install
```
3. Create a branch for your changes
```shell
$ git checkout -b my_bug_fix
```
4. Make any changes
5. Write tests to support those changes.  
6. Run the tests:
  * `bundle exec rake vcr:test`
7. Assuming the tests pass, open a Pull Request on Github.

# Using Rakefile Commands
This repository comes with five Rake commands to assist in your testing of the code.

## `rake spec`
This command will run Rspec tests normally on your local system. Be careful that VCR will behave "weirdly" if you currently have the Docker daemon running.

## `rake quality`
This command runs a code quality threshold checker to hinder bad code.

## `rake vcr`
This gem uses [VCR](https://relishapp.com/vcr/vcr) to record and replay HTTP requests made to the Docker API. The `vcr` namespace is used to record and replay spec tests inside of a Docker container. This will allow each developer to run and rerecord VCR cassettes in a consistent environment.

### Setting Up Environment Variables
Certain Rspec tests will require your credentials to the Docker Hub. If you do not have a Docker Hub account, you can sign up for one [here](https://hub.docker.com/account/signup/). To avoid hard-coding credentials into the code the test suite leverages three Environment Variables: `DOCKER_API_USER`, `DOCKER_API_PASS`, and `DOCKER_API_EMAIL`. You will need to configure your work environment (shell profile, IDE, etc) with these values in order to successfully re-record VCR cassettes.

```shell
export DOCKER_API_USER='your_docker_hub_user'
export DOCKER_API_PASS='your_docker_hub_password'
export DOCKER_API_EMAIL='your_docker_hub_email_address'
```

### `rake vcr:spec`
This command will download the necessary Docker images and then run the Rspec tests while recording your VCR cassettes.

### `rake vcr:unpack`
This command will download the necessary Docker image.

### `rake vcr:record`
This is the command you will use to record a new set of VCR cassettes. This command runs the following procedures:
1. Delete the existing `spec/vcr` directory.
2. Launch a temporary local Docker registry
3. Record new VCR cassettes by running the Rspec test suite against a live Docker daemon.
