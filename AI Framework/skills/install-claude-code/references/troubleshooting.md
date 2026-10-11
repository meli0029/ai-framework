# Claude Code and Fabric MCP troubleshooting

Use the section matching the failed stage, then rerun that check.

## `claude: command not found`

- Run `scripts/install-claude-code.sh --check`.
- If `~/.local/bin/claude` exists, confirm `~/.local/bin` is on `PATH` and start a new shell.
- If only a VS Code extension binary is found, install the standalone CLI. Do not link the versioned extension binary.
- On WSL, install Claude inside WSL.

## Claude account authentication fails

- Run `claude` in the user's own interactive terminal and retry login.
- Confirm the account includes Claude Code access.
- Run `claude doctor` and report its non-secret diagnostics.
- Check proxy, firewall, DNS, and supported-region restrictions.

## Claude requires updated terms review

- Treat `[ACTION REQUIRED]` for Consumer Terms or Privacy Policy as a user-only legal checkpoint.
- Launch `claude` in the user's interactive terminal and ask them to review and respond to the prompt themselves.
- Never accept terms on the user's behalf.
- After the user confirms completion, rerun the read-only Fabric test.

## Azure tenant mismatch or Azure CLI is logged out

- Run `az account show --query tenantId -o tsv`.
- Run `configure-fabric-mcp.sh --login --tenant-id <expected-tenant-id> --workspace-id <known-workspace-id>` so the workflow launches `az login --tenant <expected-tenant-id>` and verifies the resulting tenant.
- Never ask for passwords, MFA codes, or tokens in chat.
- Rerun `configure-fabric-mcp.sh --preflight`.

## No tenant is configured in the repository

- Ask the user for the Microsoft Entra tenant ID; do not guess it.
- Validate that it is a UUID. Tenant IDs are non-secret identifiers.
- Ask whether to record it as `FABRIC_TENANT_ID` in the repository-approved, ignored `config/fabric.env` file.
- Do not write the file until the user answers.

## Local Fabric MCP package fails to start

- Verify `node --version` is 20 or later and `npm --version` and `npx --version` succeed.
- Run `npx -y @microsoft/fabric-mcp@latest server start --mode all --help` in a trusted terminal to expose package startup errors.
- Check npm registry connectivity, proxy settings, DNS, and corporate allowlists.
- Confirm `claude mcp get fabric` shows `npx`, `@microsoft/fabric-mcp@latest`, `server start --mode all`, and `AZURE_TOKEN_CREDENTIALS=AzureCliCredential`.

## Local Fabric MCP cannot authenticate

- Run `az account show --query tenantId -o tsv` and confirm it matches the configured tenant.
- Run the helper with `--login` to refresh the correct tenant session.
- Keep `AZURE_TOKEN_CREDENTIALS=AzureCliCredential` on the MCP definition so VS Code credentials do not unexpectedly take precedence.
- Confirm the signed-in user already has the required Fabric workspace access; do not grant access automatically.

## Remote Core dynamic client registration is unsupported

- Treat `Incompatible auth server: does not support dynamic client registration` as an OAuth client-registration failure, not a network failure.
- Ask the user or tenant administrator to create a single-tenant public-client Entra app registration in the expected tenant.
- Configure the exact Claude callback URI `http://localhost:<callback-port>/callback` and least-privilege delegated Fabric permissions.
- Do not create the app, grant consent, or add permissions without explicit authorization.
- Use the local stdio Fabric MCP path when its capabilities meet the need; it reuses Azure CLI login and needs no separate app registration.
- If remote Core is explicitly required, recreate its MCP entry with `--client-id <application-client-id> --callback-port <port>`; do not use a client secret.

## `/mcp` does not show `fabric`

- Run `claude mcp get fabric` from the same repository directory.
- Confirm the local project path and MCP scope.
- Add the definition again only if it is absent.

## Browser does not open under WSL

- Invoke the `install-wsl-browser-bridge` skill.
- Retry `/mcp`; if Claude prints a URL, open it in the user's browser.
- If callback navigation fails, follow Claude's prompt to paste the full callback URL. Do not paste it into chat because it may contain sensitive authorization data.

## Azure CLI selects the wrong tenant

- Sign out of the unintended Microsoft account in the browser or use a private browser window.
- Run the helper with `--login` and select an account belonging to the expected tenant.
- Verify by finding the repository's known workspace ID with the read-only test prompt.

## Network or DNS failure

- Resolve the hostname with `getent hosts api.fabric.microsoft.com` or the platform equivalent.
- Test HTTPS reachability without credentials.
- Check VPN, proxy, DNS, firewall, and corporate allowlists.
- Retry `claude mcp get fabric` after connectivity is restored. For the local server, also confirm access to the npm registry and Microsoft Fabric endpoints.

## MCP shows connected but the workspace is absent

- Confirm the browser-authenticated Entra account belongs to the expected tenant.
- Confirm the user has at least read access to the known workspace.
- Do not grant permissions automatically. Ask a workspace administrator when access is missing.
- If the known production workspace is intentionally hidden, select another approved known workspace ID and document the test target.

## Tool call is forbidden or unavailable

- Confirm Fabric is enabled for the tenant and the Core MCP preview is available.
- Confirm the user's Fabric RBAC role permits the read operation.
- Use a read-only workspace listing as the baseline test; do not test with create, update, delete, run, refresh, or permission operations.
- Capture the non-secret error text and suggest the smallest matching remediation.
