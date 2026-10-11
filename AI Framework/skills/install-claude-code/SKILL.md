---
name: install-claude-code
description: "Install or troubleshoot the official Claude Code CLI on Linux, WSL, or macOS. When explicitly requested, connect Microsoft Fabric MCP using cached Azure CLI authentication and verify the target tenant and workspace."
---

# Install and Connect Claude Code

For CLI installation or repair, complete section 2 and stop after verifying the CLI. Only continue through Fabric setup when the user explicitly requests that integration. For requested Fabric integration, default to Microsoft's local Fabric MCP server over stdio. It reuses `az login` through `AzureCliCredential` and does not require a separate Entra app registration.

## 1. Resolve repository context

For Fabric integration, work from the client repository root. Read `README.md`, `docs/fabric-guardrails.md`, `docs/security-and-secret-handling.md`, `config/fabric.env` when present, and `config/fabric.env.example`.

If those files are absent, use the client's equivalent documentation and report missing guidance. Do not guess identifiers. The framework standards live under `AI Framework/standards/` in its checkout.

Resolve `FABRIC_TENANT_ID` and a known workspace ID. Prefer `config/fabric.env`, then the tracked example or documented registry. Treat an empty value, malformed UUID, or placeholder such as `TBD` as missing.

If no tenant is configured, ask the user for the Microsoft Entra tenant ID. Explain that it is a non-secret identifier. After receiving it, ask whether to save it as `FABRIC_TENANT_ID` in the ignored, repository-approved `config/fabric.env`. Do not write the file without their answer. Never infer a tenant from an unrelated subscription.

## 2. Install Claude Code

Resolve bundled scripts relative to this `SKILL.md`.

1. Run `scripts/install-claude-code.sh --check`.
2. If only the VS Code extension binary exists, explain that it is not a stable terminal installation.
3. If the standalone CLI is missing, request approval for network access and home-directory writes, then run `scripts/install-claude-code.sh --install`.
4. Use `--channel stable` only when requested; otherwise use `latest`.
5. Rerun `--check`. Do not continue until `claude --version` succeeds.

Launch `claude` interactively after installation. Have the user complete Claude account login and review or accept any required Anthropic terms themselves. Pause until they confirm the interactive onboarding finishes. Never accept legal terms for the user and never request or capture Claude credentials.

## 3. Validate local MCP prerequisites

Run:

```bash
scripts/configure-fabric-mcp.sh --preflight \
  --tenant-id <expected-tenant-id> \
  --workspace-id <known-workspace-id>
```

Require Azure CLI plus Node.js, npm, and npx. Require Node.js 20 or later because the official `@microsoft/fabric-mcp` package needs it.

## 4. Authenticate the expected tenant

Request approval to launch interactive Azure authentication, then run:

```bash
scripts/configure-fabric-mcp.sh --login \
  --tenant-id <expected-tenant-id> \
  --workspace-id <known-workspace-id>
```

The helper must run `az login --tenant <expected-tenant-id>` when logged out or using another tenant, then verify the active tenant matches exactly. Pause for the user-controlled browser flow. Never request, print, or store a password, MFA code, access token, refresh token, or client secret.

## 5. Add the local Fabric MCP server

Run from the target repository:

```bash
scripts/configure-fabric-mcp.sh --configure \
  --tenant-id <expected-tenant-id> \
  --workspace-id <known-workspace-id>
```

Only configure an MCP entry when that configuration is explicitly in the user's requested scope. For a new setup, add the server directly. Do not run `claude mcp remove` when no entry exists. The helper configures the equivalent of:

```bash
claude mcp add \
  --transport stdio \
  fabric \
  -e AZURE_TOKEN_CREDENTIALS=AzureCliCredential \
  -- npx -y @microsoft/fabric-mcp@latest server start --mode all
```

Use Claude's default local scope so configuration remains private to the user and this repository. If an entry named `fabric` already exists with another URL or command, inspect it and ask before replacing it. Never silently remove an existing MCP entry.

## 6. Verify and test

Run:

```bash
scripts/configure-fabric-mcp.sh --verify \
  --tenant-id <expected-tenant-id> \
  --workspace-id <known-workspace-id>
```

Start Claude from the repository and enter `/mcp`. The local `fabric` server should show connected; it does not need a separate MCP OAuth login.

Then run this read-only test prompt with the resolved workspace ID:

```text
Use only the local Fabric MCP server. List the Fabric workspaces I can access and confirm whether workspace ID <known-workspace-id> is present. Do not create, update, delete, upload, run, refresh, sync, or change anything. Report the workspace name and ID only.
```

Success requires:

1. `claude --version` succeeds.
2. Claude account onboarding and any required terms review are complete.
3. Azure CLI is authenticated to the expected tenant.
4. `claude mcp get fabric` shows stdio transport, `npx`, `@microsoft/fabric-mcp@latest`, `--mode all`, and `AzureCliCredential`.
5. The MCP server connects without a startup or authentication error.
6. The read-only prompt returns Fabric data and finds the known workspace ID.

If the known workspace is absent, treat the test as failed or inconclusive; verify tenant selection and workspace access.

## 7. Report failures and completion

Report the CLI path/version, Node version, active tenant, MCP scope/command/status, test workspace ID, read-only test result, and remaining actions. Never print secrets or sensitive data.

For any failed check, read [references/troubleshooting.md](references/troubleshooting.md), identify the exact failed stage, give matching next steps, and rerun the failed check plus downstream checks after remediation.

## Remote Core MCP exception

Use `https://api.fabric.microsoft.com/v1/mcp/core` only when the user explicitly requires remote Core features missing from the local server. Explain that external clients may require a tenant-owned public-client Entra app registration because Microsoft Entra does not support dynamic client registration for that endpoint. Do not create an app registration or change permissions without explicit authorization.

## Guardrails

- Prefer official Anthropic and Microsoft installers/packages.
- Install inside WSL for WSL-hosted repositories.
- Do not alias or symlink versioned VS Code extension binaries.
- Do not edit shell startup files unless necessary and authorized.
- Do not perform a Fabric write as a connection test.
- Follow the client repository's Fabric guardrails before every Fabric action.

## Official references

- [Claude Code setup](https://code.claude.com/docs/en/setup)
- [Claude Code MCP configuration](https://code.claude.com/docs/en/mcp)
- [Microsoft MCP servers](https://github.com/microsoft/mcp/tree/main/servers/Fabric.Mcp.Server)
