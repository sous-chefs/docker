# Plan: Implement Missing Docker Resources (2025-2026 Features)

This plan outlines the implementation of resources for Docker features that are currently unsupported in the `docker` cookbook, focusing on Swarm management and AI-native capabilities.

## Objective

- Add support for core Swarm resources: `docker_secret` and `docker_config`.
- Add support for AI-native Docker features: `docker_model` and `docker_mcp`.
- Enhance `docker_container` to support `type=image` mounts.
- Add `docker_context` for endpoint management.

## Proposed Resources

### 1. Swarm Management

- **`docker_secret`**: Manage Docker secrets (`docker secret create/rm/inspect`).
- **`docker_config`**: Manage Docker configs (`docker config create/rm/inspect`).

### 2. AI & Model Management (Docker v28+)

- **`docker_model`**: Resource to pull and manage local LLMs using the new `docker model` CLI.
- **`docker_mcp`**: Manage Model Context Protocol (MCP) servers and configurations.

### 3. Storage Enhancements

- **`docker_container` updates**: Add support for `image` type in the `mounts` property to leverage direct layer mounting.

### 4. Utility Resources

- **`docker_context`**: Manage Docker contexts for switching between local and remote engines.

## Implementation Steps

### Phase 1: Swarm Secrets and Configs

1. Create `resources/secret.rb`.
2. Create `resources/config.rb`.
3. Add corresponding unit tests in `spec/unit/resources/`.
4. Add integration tests in a new `test/cookbooks/test/recipes/swarm_resources.rb`.

### Phase 2: AI-Native Features

1. Research the `docker-api` gem's support for the new model and MCP endpoints.
2. Implement `resources/model.rb` if CLI execution is required or API is available.
3. Implement `resources/mcp.rb`.

### Phase 3: Container & Context

1. Update `resources/container.rb` properties.
2. Create `resources/context.rb`.

## Verification & Testing

- **Unit Tests**: Ensure 100% coverage for new resources using ChefSpec.
- **Integration Tests**: Expand Swarm suites to exercise secrets and configs.
- **Documentation**: Add new files to `documentation/` for each resource.
