# docker_plugin

The `docker_plugin` resource allows you to install, configure, enable, disable and remove [Docker Engine managed plugins](https://docs.docker.com/engine/extend/).

## Actions

- `:install` - Install and configure a plugin if it is not already installed
- `:update` - Re-configure a plugin
- `:enable` - Enable a plugin (needs to be done after `:install` before it can
  be used)
- `:disable` - Disable a plugin (needs to be done before removing a plugin)
- `:remove` - Remove a disabled plugin

## Properties

- `local_alias` - Local name for the plugin (defaults to the resource name).
- `remote` - Ref of the plugin (e.g. `vieux/sshfs`). Defaults to `local_alias` or the resource name. Only used for `:install`.
- `remote_tag` - Remote tag of the plugin to pull (e.g. `1.0.1`, defaults to `latest`) Only used for `:install`.
- `options` - Hash of options to set on the plugin. Only used for `:update` and `:install`.
- `grant_privileges` - Array of privileges or true. If it is true, all privileges requested by the plugin will be automatically granted (potentially dangerous). Otherwise, this must be an array in the same format as returned by the [`/plugins/privileges` docker API](https://docs.docker.com/engine/api/v1.37/#operation/GetPluginPrivileges) endpoint. If the array of privileges is not sufficient for the plugin, docker will reject it and the installation will fail. Defaults to `[]` (empty array => no privileges). Only used for `:install`. Does not modify the privileges of already-installed plugins.

## Examples

```ruby
docker_plugin 'rbd' do
  remote 'wetopi/rbd'
  remote_tag '1.0.1'
  grant_privileges true
  options(
    'RBD_CONF_POOL' => 'docker_volumes'
  )
end
```
