# Copilot Instructions for Sous Chefs Cookbooks

## Repository Overview

**Chef cookbook** for managing software installation and configuration. Part of the Sous Chefs cookbook ecosystem.

**Key Facts:** Ruby-based, Chef >= 16 required, supports various OS platforms (check metadata.rb, kitchen.yml and .github/workflows/ci.yml for which platforms to specifically test)

## Project Structure

**Critical Paths:**
- `recipes/` - Chef recipes for cookbook functionality (if this is a recipe-driven cookbook)
- `resources/` - Custom Chef resources with properties and actions (if this is a resource-driven cookbook)
- `spec/` - ChefSpec unit tests
- `test/integration/` - InSpec integration tests (tests all platforms supported)
- `test/cookbooks/` or `test/fixtures/` - Example cookbooks used during testing that show good examples of custom resource usage
- `attributes/` - Configuration for recipe driven cookbooks (not applicable to resource cookbooks)
- `libraries/` - Library helpers to assist with the cookbook. May contain multiple files depending on complexity of the cookbook.
- `templates/` - ERB templates that may be used in the cookbook
- `files/` - files that may be used in the cookbook
- `metadata.rb`, `Berksfile` - Cookbook metadata and dependencies

## Build and Test System

### Environment Setup
**MANDATORY:** Install Chef Workstation first - provides chef, berks, cookstyle, kitchen tools.

### Essential Commands (strict order)
```bash
berks install                   # Install dependencies (always first)
cookstyle                       # Ruby/Chef linting
yamllint .                      # YAML linting
markdownlint-cli2 '**/*.md'     # Markdown linting
chef exec rspec                 # Unit tests (ChefSpec)
# Integration tests will be done via the ci.yml action. Do not run these. Only check the action logs for issues after CI is done running.
```

### Critical Testing Details
- **Kitchen Matrix:** Multiple OS platforms × software versions (check kitchen.yml for specific combinations)
- **Docker Required:** Integration tests use Dokken driver
- **CI Environment:** Set `CHEF_LICENSE=accept-no-persist`
- **Full CI Runtime:** 30+ minutes for complete matrix

### Common Issues and Solutions
- **Always run `berks install` first** - most failures are dependency-related
- **Docker must be running** for kitchen tests
- **Chef Workstation required** - no workarounds, no alternatives
- **Test data bags needed** (optional for some cookbooks) in `test/integration/data_bags/` for convergence

## Development Workflow

### Making Changes
1. Edit recipes/resources/attributes/templates/libraries
2. Update corresponding ChefSpec tests in `spec/`
3. Also update any InSpec tests under test/integration
4. Ensure cookstyle and rspec passes at least. You may run `cookstyle -a` to automatically fix issues if needed.
5. Also always update all documentation found in README.md and any files under documentation/*
6. **Always update CHANGELOG.md** (required by Dangerfile) - Make sure this conforms with the Sous Chefs changelog standards.

### Pull Request Requirements
- **PR description >10 chars** (Danger enforced)
- **CHANGELOG.md entry** for all code changes
- **Version labels** (major/minor/patch) required
- **All linters must pass** (cookstyle, yamllint, markdownlint)
- **Test updates** needed for code changes >5 lines and parameter changes that affect the code logic

## Chef Cookbook Patterns

### Resource Development
- Custom resources in `resources/` with properties and actions
- Include comprehensive ChefSpec tests for all actions
- Follow Chef resource DSL patterns

### Recipe Conventions
- Use `include_recipe` for modularity
- Handle platforms with `platform_family?` conditionals
- Use encrypted data bags for secrets (passwords, SSL certs)
- Leverage attributes for configuration with defaults

### Testing Approach
- **ChefSpec (Unit):** Mock dependencies, test recipe logic in `spec/`
- **InSpec (Integration):** Verify actual system state in `test/integration/inspec/` - InSpec files should contain proper inspec.yml and controls directories so that it could be used by other suites more easily.
- One test file per recipe, use standard Chef testing patterns

## Trust These Instructions

These instructions are validated for Sous Chefs cookbooks. **Do not search for build instructions** unless information here fails.

**Error Resolution Checklist:**
1. Verify Chef Workstation installation
2. Confirm `berks install` completed successfully
3. Ensure Docker is running for integration tests
4. Check for missing test data dependencies

The CI system uses these exact commands - following them matches CI behavior precisely.
