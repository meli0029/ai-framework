# AI Framework

A reusable, technology-agnostic framework for AI-assisted software engineering and data platform delivery.

This repository provides a standardized foundation for building AI-enabled engineering environments across multiple technologies, including Microsoft Fabric, PostgreSQL, dbt, Databricks, Python, Power BI, Snowflake, and future platforms.

Rather than recreating AI context for every engagement, this framework provides reusable engineering knowledge, AI skills, implementation playbooks, engineering standards, templates, examples, and installation tooling that can be incorporated into client implementations.

The framework is designed to work alongside modern AI coding assistants including Codex, ChatGPT, Claude Code, GitHub Copilot, Cursor, and future agentic development tools.

---

# Repository Structure

```text
AI Framework/
    knowledge/
    skills/
    playbooks/
    standards/
    templates/
    examples/
    tools/

scripts/

AGENTS.md
```

## AI Framework

Contains the reusable engineering framework that can be incorporated into client repositories.

## scripts

Contains installer and maintenance scripts responsible for installing and maintaining supported AI integrations.

Examples include:

* Microsoft Fabric Skills
* PostgreSQL AI
* dbt AI
* Databricks Skills

## AGENTS.md

Defines repository-wide behavior and operating guidance for AI coding agents.

---

# Design Principles

This framework is built around several core principles.

* Reuse engineering knowledge across clients whenever practical.
* Prefer official vendor guidance over community implementations.
* Keep documentation small, focused, and AI-friendly.
* Separate reusable engineering knowledge from client-specific implementations.
* Treat documentation as version-controlled source code.
* Build reusable frameworks rather than one-off solutions.

---

# Vendor Integration Principles

This repository is an orchestrator, not a vendor distribution.

When official AI capabilities are available from a technology vendor, installers should use the vendor-supported installation method whenever possible.

Examples include:

* Microsoft Fabric Skills
* Databricks Agent Skills
* dbt AI
* PostgreSQL AI (Timescale pg-aiguide)

Do not vendor copies of official repositories into this framework.

Do not fork vendor repositories unless there is a documented business requirement.

Installers should always retrieve the latest supported version from the official source whenever practical.

Community tooling should only be used when:

* no official vendor solution exists,
* it is actively maintained,
* and it has been intentionally approved for inclusion in this framework.

---

# Purpose

The goal of this repository is to accelerate engineering delivery by giving both engineers and AI assistants access to curated engineering knowledge, reusable implementation patterns, standardized workflows, and vendor-supported AI capabilities.

Client implementations should consume this framework and extend it with client-specific knowledge rather than recreating common engineering practices from scratch.
