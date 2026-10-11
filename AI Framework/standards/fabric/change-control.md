# Fabric Guardrails

This document defines the safety rules for Microsoft Fabric development, testing, deployment, and production changes in this repository.

The goal is simple: make development easy, but make accidental production changes hard.

## Core principle

All changes should move through a controlled path:

```text
feature or personal development branch
    -> development Fabric workspace
    -> reviewed integration branch
    -> approved deployment process
    -> production Fabric workspace
```

Production must not be used as a scratchpad.

## Environment roles

| Environment | Purpose | Allowed work |
|---|---|---|
| Personal development workspace | Individual testing | Build, break, test, and iterate. |
| Shared development workspace | Integrated testing | Validate changes before promotion. |
| Production workspace | Business operations | Only approved releases and explicitly approved emergency fixes. |

## Workspace registry

Keep tenant, workspace IDs, environment roles, and branch mappings in the client repository. Resolve the target before any Fabric action; never assume `main` means production. This framework carries no client registry or standing authorization.

## Non-negotiable rules

- Do not make production changes unless the user explicitly approves the specific production action in the current conversation.
- Do not sync Git directly into production unless explicitly approved.
- Do not casually promote schedule changes to production.
- Do not drop, rename, or remove report-facing columns without explicit approval.
- Do not store secrets, tokens, passwords, or connection strings in the repository.
- Validate row counts and financial totals before and after reporting-table changes.
- Prefer additive changes over breaking changes.
- If the target workspace is unclear, stop and verify before acting.

Authorization to inspect, diagnose, inventory, or recommend a fix does not authorize implementing the fix.

## Production protection

Production access is read-only by default.

Production changes require an explicit statement that identifies the production action, such as:

> Deploy this to production.

or:

> Apply this change in the `<production-workspace>` production workspace.

Ambiguous requests are not production approval. Examples include:

- "sync it"
- "push it"
- "make it live"
- "update Fabric"
- "test this"

If there is any doubt, verify which workspace and environment should be changed.

Do not perform any production write or side-effecting operation without action-specific approval. This includes:

- Creating, updating, renaming, moving, or deleting Fabric items.
- Changing notebook, pipeline, Lakehouse, Warehouse, semantic model, or report definitions.
- Modifying tables, views, procedures, schemas, or data.
- Changing connections, credentials, workspace roles, identities, or permissions.
- Enabling, disabling, or changing schedules and triggers.
- Running pipelines, notebooks, refreshes, deployments, backfills, or Git synchronization.
- Connecting a production workspace to Git.
- Assigning capacity or changing workspace settings.

Before an approved production change:

1. Confirm the active tenant.
2. Confirm the exact workspace and item IDs.
3. Describe the intended change and expected impact.
4. Use the smallest scoped change.
5. Validate the result without expanding the approved scope.

## Git and deployment flow

Development should happen in a development branch and development workspace.

Use this flow:

1. Create or update a feature or personal branch.
2. Push changes to Git after the external Git operation is authorized.
3. Sync the development Fabric workspace after the Fabric change is authorized.
4. Test notebooks, pipelines, semantic models, and reports in development.
5. Open a pull request or promote reviewed changes into the approved integration branch.
6. Use Fabric deployment pipelines or another approved release process to move changes to production.

Do not use Git synchronization as the default production deployment mechanism.

## Schedule safety

Fabric schedule files and pipeline schedules are high-risk.

Before promoting schedule changes:

1. Inspect the diff.
2. Check whether `enabled` changed.
3. Confirm whether development schedules are intentionally disabled.
4. Confirm whether production schedules should remain enabled.
5. Obtain explicit approval before changing production schedules.

Production schedules may intentionally differ from development schedules.

## Warehouse and semantic model safety

Before changing Warehouse tables, views, stored procedures, semantic models, or report-fed schemas:

1. Identify downstream reports and semantic models.
2. Confirm the table grain.
3. Prefer adding columns over renaming or removing columns.
4. Do not change existing financial logic unless that is the stated goal.
5. Check row counts before and after.
6. Check key financial totals before and after.
7. Check for duplicate keys and unexpected nulls.
8. Document semantic-model and report break risk.

Breaking changes require explicit approval. Examples include:

- Dropping or renaming a column.
- Changing a key.
- Changing fact-table grain.
- Changing net sales, revenue, margin, quantity, or order-count definitions.
- Replacing a table with a different shape.
- Changing relationships in a semantic model.

## Notebook and pipeline safety

For notebook or pipeline changes:

- Make minimal edits.
- Preserve Fabric metadata files and item structure.
- For notebooks, read and apply `AI Framework/standards/fabric/notebook-development.md` before authoring or publishing.
- Before creating or updating a Fabric notebook item, export the proposed `.ipynb` and run `python3 scripts/validate-fabric-notebook.py <notebook.ipynb>`.
- Treat any failed structural, formatting, annotation, secret, metadata, or validation check as a publication blocker. API acceptance is not evidence of standards conformance.
- Capture the validator result before the Fabric write and report it in the closeout.
- Sync changes into the development workspace before testing.
- Restart Spark sessions when environment or dependency changes are involved.
- Run a small smoke test before a large backfill or full refresh.
- Do not trigger high-volume production runs without explicit approval.

### Required notebook publication gate

A notebook must not be published or promoted unless all applicable checks below pass:

1. The first cell is a plain-English Markdown overview.
2. The second cell is a tagged parameters cell with no credential values.
3. Imports are grouped and visually annotated.
4. Major processing stages are separated into cohesive, titled cells; oversized mixed-responsibility cells are rejected.
5. Prerequisites, schemas, processing, and final validation are visibly distinct.
6. The intended workspace is verified and default Lakehouse metadata is present when the workload uses a Lakehouse.
7. Outputs are cleared and empty or temporary cells are removed.
8. Sensitive literal scanning passes.
9. The final cell reports operational status, processed counts, remaining work, and elapsed time when applicable.
10. `scripts/validate-fabric-notebook.py` exits successfully against the exact definition being uploaded.

If an exception is necessary, document the failed check, reason, risk, and the user's explicit approval before publishing. A later visual review is not a substitute for this gate.

## Data refresh and destructive actions

The following actions require explicit approval:

- Full reloads.
- Table drops.
- Table truncation.
- Hard deletes.
- Credential resets.
- Production pipeline or notebook runs.
- Production refreshes and deployments.
- Changes to production schedules.
- Changes to production workspace Git integration.
- Deletion of Fabric items.
- Deletion of branches connected to Fabric workspaces.

Resolve exact targets with read-only checks before any destructive action. Prefer recoverable and additive approaches when practical.

## Secrets and authentication

Never commit, print, paste, or log:

- Access tokens.
- Refresh tokens.
- Passwords.
- Personal access tokens.
- Client secrets.
- Private keys.
- Raw connection strings containing secrets.
- Exported credential files.

Use approved authentication helpers, Key Vault, environment variables, Workspace Identity, service principals, or Fabric connections as appropriate.

If a command prints a token or secret, stop. Do not paste it into chat, logs, documentation, tickets, or commits.

Never request a password through chat or place one in a command argument, environment variable, file, or tool input. Require the user to authenticate through an appropriate interactive prompt.

## Required pre-change checklist

Before making a Fabric change, answer:

- What workspace is the target?
- Is the environment development or production?
- What branch is involved?
- What Fabric item is changing?
- Are schedules affected?
- Are downstream reports or semantic models affected?
- Is the change additive or breaking?
- How will the change be tested?
- Which applicable engineering standard governs the artifact, and what pre-publish validator or checklist will prove conformance?

## Required closeout checklist

After making a Fabric change, report:

- Files and Fabric items changed.
- Workspace affected.
- Branch affected.
- Whether Fabric synchronization was run.
- Whether tests were run.
- The applicable standards and pre-publish validation result.
- Row-count and amount validation, when relevant.
- Known risks.
- What remains before production.

## Emergency fixes

Emergency production fixes are allowed only when explicitly approved.

For an approved emergency fix:

1. State the production target.
2. State the exact change.
3. Make the smallest possible change.
4. Capture before-and-after validation.
5. Back-port the fix into the normal Git and development flow.
6. Document what happened.
