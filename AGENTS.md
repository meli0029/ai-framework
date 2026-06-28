# AI Framework Agent Instructions

This repository provides the reusable AI engineering framework used across multiple client implementations.

Your role is to preserve consistency, maximize reuse, and leverage official vendor AI capabilities whenever available.

---

# Repository Layout

## AI Framework/

Contains reusable engineering assets.

### knowledge/

Reference documentation.

Contains wiki-style engineering knowledge describing technologies, concepts, architectures, implementation guidance, and reference material.

### skills/

Reusable AI skills.

Skills teach AI assistants how to perform specific engineering tasks.

Examples include:

* Build a Fabric notebook
* Review SQL
* Design a semantic model
* Build a dbt model

### playbooks/

End-to-end engineering workflows.

Playbooks combine multiple skills into repeatable delivery processes.

### standards/

Engineering standards, conventions, and architectural decisions.

### templates/

Reusable starting points.

### examples/

Production-quality reference implementations.

### tools/

Utilities that belong to the framework itself.

---

# scripts/

Contains installer and maintenance scripts.

Current installers include:

* install-framework.sh
* install-fabric-skills.sh
* install-postgres-ai.sh
* install-dbt-ai.sh
* install-databricks-skills.sh

---

# Installer Rules

Always prefer the master installer.

Examples:

```bash
./scripts/install-framework.sh --fabric
./scripts/install-framework.sh --postgres
./scripts/install-framework.sh --dbt
./scripts/install-framework.sh --databricks
./scripts/install-framework.sh --all
```

Install only the technologies required for the current client implementation.

Do not install technologies that are unrelated to the current engagement.

---

# Vendor Integration Rules

Installers should ONLY use official installation methods provided by the technology vendor whenever they exist.

Do not recreate, fork, vendor, or modify official vendor AI tooling unless explicitly directed.

Vendor repositories should remain external dependencies and should be updated from their official upstream sources.

Community tooling should only be used when:

* no official vendor solution exists,
* it is actively maintained,
* and it has been intentionally approved for inclusion in this framework.

---

# Framework Behavior

When adding content:

* Place conceptual documentation in `knowledge`.
* Place reusable task guidance in `skills`.
* Place end-to-end workflows in `playbooks`.
* Place engineering conventions and architectural decisions in `standards`.
* Place reusable starting points in `templates`.
* Place production-quality reference implementations in `examples`.

Avoid duplicating information.

Prefer referencing existing documentation over creating multiple sources of truth.

Favor official vendor documentation over community articles whenever practical.

Treat this framework as a long-lived engineering asset rather than a project-specific repository.
