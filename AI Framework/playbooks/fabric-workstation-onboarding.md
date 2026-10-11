# Fabric workstation onboarding

Run this workflow from the client repository, using its `AGENTS.md`, workspace registry, and security guidance. The framework supplies reusable tooling, not environment authorization.

1. Check prerequisites with `scripts/bootstrap-fabric-tools.sh --check` or `scripts/bootstrap-fabric-tools.ps1 -Check` from the framework checkout. Install missing tools only within the user's requested setup scope. Bash supports Debian/Ubuntu/WSL and macOS; PowerShell uses WinGet on Windows.
2. Install framework skills with the master installer. For official Fabric skills, install Microsoft's [APM CLI](https://microsoft.github.io/apm/) and use `--fabric` or `-Fabric`. Node.js/npm are additional prerequisites only for the optional Claude Fabric MCP workflow.
3. Copy the [non-secret environment template](../templates/fabric/fabric.env.example) to the client's ignored `config/fabric.env`, when authorized. Resolve the expected tenant and target workspace from client documentation or the user. `TBD` is not an executable target. Never source an untrusted environment file as shell code.
4. Inspect cached login with `az account show --query tenantId -o tsv`. When authentication is needed, the user signs in interactively with `az login --tenant <expected-tenant-id>`. Verify the resulting tenant before any Fabric request.
5. Confirm the known workspace using a read-only request:

   ```bash
   az rest --method get --resource https://api.fabric.microsoft.com \
     --url https://api.fabric.microsoft.com/v1/workspaces/<workspace-id> \
     --query '{name:displayName,id:id}' -o table
   ```

6. If access is missing, report it to the user. Onboarding does not authorize permission changes, deployments, runs, refreshes, schedules, or Git synchronization. Never substitute production for a missing development workspace.
7. Report tools, expected/active tenant, target workspace visibility, development availability, Git access, and remaining setup. Do not declare readiness when tenant or workspace checks fail.

Read the [change-control standard](../standards/fabric/change-control.md) before Fabric work and [secret-handling standard](../standards/security-and-secret-handling.md) before authentication. Client rules may be stricter.
