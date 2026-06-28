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

Examples:

* Build a Microsoft Fabric notebook
* Review SQL
* Design a semantic model
* Build a dbt model
* Optimize PostgreSQL queries

### playbooks/

End-to-end engineering workflows.

Playbooks combine multiple skills into repeatable delivery processes.

### standards/

Engineering standards, architectural decisions, naming conventions, coding standards, and implementation guidance.

### templates/

Reusable starting points for projects, documentation, notebooks, SQL, and code.

### examples/

Production-quality reference implementations.

Examples should represent best practices and production-ready solutions.

### tools/

Framework utilities and reusable tooling.

---

# scripts/

Contains installer and maintenance scripts.

Current installers include:

* install-framework.sh
* update-framework.sh
* install-fabric-skills.sh
* install-postgres-ai.sh
* install-dbt-ai.sh
* install-databricks-skills.sh
* install-power-bi-ai.sh

---

# Installer Rules

Always use the master installer whenever practical.

Examples:

```bash
./scripts/install-framework.sh --fabric
./scripts/install-framework.sh --postgres
./scripts/install-framework.sh --dbt
./scripts/install-framework.sh --databricks
./scripts/install-framework.sh --power-bi
./scripts/install-framework.sh --all
```

Install only the technologies required for the current client implementation.

Do not install technologies that are unrelated to the current engagement.

---

# Vendor Integration Principles

The AI Framework is an orchestrator—not a vendor distribution.

Whenever official AI tooling exists for a technology, installers must use the vendor's official installation method.

Examples include:

* Microsoft Fabric Skills
* PostgreSQL AI (Timescale pg-aiguide)
* dbt AI
* Databricks Agent Skills
* Microsoft Power BI AI

Do not recreate, fork, vendor, or modify official vendor tooling unless explicitly directed.

Vendor repositories should remain external dependencies whenever practical.

Installers should always retrieve the latest supported version from the official vendor whenever possible.

---

# Agent Configuration

Do not configure agent-specific settings unless explicitly requested.

This includes, but is not limited to:

* MCP server configuration
* Codex configuration
* Claude configuration
* Cursor configuration
* GitHub Copilot configuration
* Editor-specific settings
* Local AI agent configuration files

These configurations should remain the responsibility of the vendor's official installer and documentation.

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

Prefer reusable, technology-agnostic solutions unless a client-specific implementation is required.
