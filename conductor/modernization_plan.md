# Plan: Modernize Docker Cookbook

This plan outlines the steps to modernize the `docker` cookbook by removing EOL platforms, adding support for newer distributions, and cleaning up legacy code.

## Objective

- Sync supported platforms across `metadata.rb`, Kitchen files, and CI.
- Remove EOL platforms (Ubuntu 20.04, Debian 11, AlmaLinux 8, Rocky Linux 8).
- Add support for new platforms (Debian 13, AlmaLinux 10, Rocky Linux 10).
- Remove legacy `sysvinit` and `upstart` templates.
- Ensure all resources follow modern Sous Chefs patterns.

## Key Files & Context

- `metadata.rb`: Supported platforms and version.
- `kitchen.yml`, `kitchen.dokken.yml`: Integration test platforms.
- `.github/workflows/ci.yml`: CI matrix.
- `resources/installation_package.rb`: Platform-specific installation logic.
- `templates/default/`: Legacy init templates.

## Implementation Steps

### Phase 1: Platform Modernization

1. **Update `metadata.rb`**:
   - Refine `supports` to be more specific if possible, or ensure it accurately reflects the current state.
   - Update `chef_version` to `>= 16.0`.
2. **Update `kitchen.yml`**:
   - Remove `ubuntu-20.04`, `almalinux-8`, `rockylinux-8`.
   - Add `almalinux-10`, `rockylinux-10`, `debian-13`.
3. **Update `kitchen.dokken.yml`**:
   - Remove `ubuntu-20.04`, `almalinux-8`, `rockylinux-8`, `opensuse-leap-15` (if EOL).
   - Ensure it matches `kitchen.yml`.
4. **Update `.github/workflows/ci.yml`**:
   - Sync the `integration` and `smoke` matrices with the updated kitchen platforms.

### Phase 2: Resource Updates

1. **Modernize `resources/installation_package.rb`**:
   - Add `trixie?` helper for Debian 13.
   - Update `version_string` to handle Debian 13.
   - Update `apt_repository` `signed_by` logic for newer Debian/Ubuntu.
2. **Cleanup Legacy Code**:
   - Delete `templates/default/sysvinit/` directory.
   - Delete `templates/default/upstart/` directory.

### Phase 3: Documentation & Maintenance

1. **Version Bump**: Increment version in `metadata.rb`.
2. **Verify Docs**: Ensure Swarm resources and other new features are accurately documented in `documentation/`.

## Verification & Testing

### Unit Testing

- Run `chef exec rspec` to ensure all unit tests pass after changes.
- Add or update specs for `installation_package` to cover Debian 13.

### Integration Testing

- Run `kitchen list` to verify updated platform list.
- Run `kitchen test default-ubuntu-2404` (or other current platform) to ensure basic functionality.

### Linting

- Run `cookstyle -a` to fix any style offenses.
