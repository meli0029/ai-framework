# AI Framework

This repository is a reusable AI-assisted engineering framework.

The goal is to provide a repeatable foundation for client implementations across multiple technologies including Microsoft Fabric, PostgreSQL, dbt, Databricks, Snowflake, Python, Power BI, and future platforms.

---

# Repository Structure

## AI Framework/

Contains reusable engineering knowledge.

### knowledge/

Reference material.

Contains wiki-style documentation explaining technologies, concepts, architectures, and implementation details.

Examples:

- Fabric Lakehouses
- Medallion Architecture
- PostgreSQL Indexing
- dbt Incremental Models

---

### skills/

Reusable AI skills.

Skills teach the AI how to perform a specific task.

Examples:

- Build a Fabric notebook
- Review SQL
- Design a semantic model
- Create a dbt model

---

### playbooks/

End-to-end workflows.

Playbooks combine multiple skills into repeatable delivery processes.

Examples:

- New Microsoft Fabric Client
- New dbt Project
- Lakehouse Implementation

---

### standards/

Engineering standards and conventions.

Examples:

- Naming standards
- SQL style
- Python style
- Repository layout
- Documentation standards

---

### templates/

Reusable starting points.

Examples:

- README templates
- Notebook templates
- Project templates

---

### examples/

Production-quality examples.

Examples should demonstrate best practices.

---

### tools/

Utilities that belong to the framework itself.

---

# scripts/

Contains installer and maintenance scripts.

Scripts are responsible for installing AI capabilities and maintaining the framework.

Current installers:

- install-framework.sh
- install-fabric-skills.sh
- install-postgres-ai.sh
- install-dbt-ai.sh
- install-databricks-skills.sh

---

# Installer Rules

Use the master installer whenever possible.

Examples:

./scripts/install-framework.sh --fabric

./scripts/install-framework.sh --postgres

./scripts/install-framework.sh --dbt

./scripts/install-framework.sh --databricks

./scripts/install-framework.sh --all

Only install technologies that are relevant to the current client.

Do not install PostgreSQL tooling for a Microsoft Fabric-only client.

Do not install Databricks tooling unless Databricks is being used.

---

# General Behavior

Prefer existing framework knowledge before inventing new content.

When adding knowledge:

- Place conceptual documentation in knowledge.
- Place reusable procedures in skills.
- Place end-to-end workflows in playbooks.
- Place engineering opinions in standards.
- Place reusable skeletons in templates.
- Place production examples in examples.

Avoid duplicating information across folders.
Reference existing documents whenever possible.