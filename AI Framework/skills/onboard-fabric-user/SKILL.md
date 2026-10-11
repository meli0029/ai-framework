---
name: onboard-fabric-user
description: Prepare a workstation for Microsoft Fabric CLI work and verify tenant and workspace access. Use for Fabric onboarding, prerequisite checks, and authentication readiness in a client repository.
---

# Onboard a Fabric User

Read the client repository's `AGENTS.md`, README, Fabric guardrails, and security instructions first. Locate the framework checkout separately; use its `AI Framework/playbooks/fabric-workstation-onboarding.md` for the workflow and its `scripts/` for installers. If it is unavailable, ask for its location rather than guessing relative paths from the installed skill.

Resolve the expected tenant and workspace from the client's documented registry or non-secret `config/fabric.env`. Reject placeholders; ask for missing IDs before accessing Fabric. This skill carries no client defaults or standing production authorization.

Run prerequisite checks first. Install only requested tools through the master installer. Keep authentication interactive and verify the expected tenant before the read-only workspace check. Never collect credentials in chat or use a Fabric write as an access test.

Report tool readiness, tenant verification, workspace visibility, development availability, and remaining steps. Missing access requires an administrator's help; do not grant permissions automatically.
