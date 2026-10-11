# Security and Secret Handling

## Rules

Never commit, print, paste, or log:

- access or refresh tokens;
- passwords or MFA codes;
- personal access tokens;
- client secrets;
- private keys;
- secret-bearing connection strings;
- exported credential files.

Tenant IDs, workspace IDs, item IDs, and server names are identifiers and may be documented when needed.

Use interactive Azure CLI authentication and its cached login for local user workflows. Do not ask an AI assistant to collect a password or MFA code, and do not place credentials in command arguments or environment variables.

## Secret providers

Use the client-approved secret provider, Fabric connections, Workspace Identity, or cached interactive authentication as appropriate. Missing infrastructure does not authorize embedded credentials. Do not copy client credential exceptions into reusable assets.

## Local files

`config/fabric.env` is for non-secret identifiers only and is ignored by Git. The framework template `AI Framework/templates/fabric/fabric.env.example` must contain no credentials.

Before committing, inspect staged changes for secrets. If a secret is committed, treat it as compromised: stop using it, rotate it, and remove it from repository history through the approved incident process.
