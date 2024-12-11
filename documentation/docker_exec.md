# docker_exec

The `docker_exec` resource allows you to execute commands inside of a running container. This is equivalent to using the `docker exec` command and is useful for running commands, scripts, or interactive shells within containers.

## Actions

- `:run` - Executes the specified command inside the container

## Properties

### Required Properties

- `container` - Name or ID of the container to execute the command in
- `command` - Command to execute, structured as an Array similar to `CMD` in a Dockerfile (alias: `cmd`)

### Optional Properties

- `host` - Docker daemon socket to connect to (default: ENV['DOCKER_HOST'])
- `timeout` - Seconds to wait for the command to complete (default: 60)
- `returns` - Expected return value(s) for the command (default: [0]). Can be a single integer or array of accepted values.

## Examples

### Basic Command Execution

```ruby
docker_exec 'create_file' do
  container 'web_app'
  command ['touch', '/tmp/test_file']
end
```

### Custom Return Values

```ruby
docker_exec 'check_status' do
  container 'app'
  command ['grep', 'pattern', '/var/log/app.log']
  returns [0, 1]  # Accept both found (0) and not-found (1) as valid returns
end
```

### Long Running Commands

```ruby
docker_exec 'database_backup' do
  container 'database'
  command ['pg_dump', '-U', 'postgres', 'mydb', '>', '/backup/db.sql']
  timeout 300  # 5 minutes timeout for backup
end
```

### Multiple Commands with Shell

```ruby
docker_exec 'setup_environment' do
  container 'web_app'
  command ['sh', '-c', 'mkdir -p /app/data && chown www-data:www-data /app/data']
end
```

## Notes

1. The container must be running when executing commands
2. The `command` property must be an array where each argument is a separate element
3. Use `sh -c` when you need to use shell features like pipes or environment variables
4. Set appropriate timeouts for long-running commands
5. Use the `returns` property to handle commands that may have multiple valid exit codes

## Common Use Cases

- Running database migrations
- Installing system packages
- Modifying configuration files
- Running maintenance tasks
- Health checks
- Log inspection
