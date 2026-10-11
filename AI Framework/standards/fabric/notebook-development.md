# Microsoft Fabric Notebook Development Standard

## Purpose

This standard defines the expected structure and operational qualities of new Microsoft Fabric notebooks. It covers scheduled and Git-backed workloads across client implementations.

## Required Notebook Structure

New notebooks should use the following cell order unless the workload has a documented reason to differ:

1. **Overview (Markdown)** — explain the notebook in plain English.
2. **Parameters (code, tagged `parameters`)** — expose safe runtime settings and pipeline overrides.
3. **Imports and runtime setup (code)** — group imports and initialize clients or sessions.
4. **Prerequisites and schemas (code)** — validate dependencies and define explicit schemas.
5. **Processing stages (code and Markdown as needed)** — organize extraction, transformation, and loading into cohesive sections.
6. **Validation and run summary (code)** — report counts, status, elapsed time, and useful follow-up information.

Avoid empty cells, abandoned test cells, and large cells that mix unrelated responsibilities.

## Opening Markdown Cell

Every notebook must begin with a Markdown cell. A reader should be able to understand the notebook without reading its code.

Include:

- notebook purpose and business outcome;
- source systems, files, or tables;
- output tables or other side effects;
- high-level processing flow;
- expected execution mode, such as manual, pipeline, hourly, or daily;
- important dependencies, including the attached Lakehouse, connections, and secret provider;
- restart, retry, idempotency, or checkpoint behavior when relevant;
- any operational limitation that would make the notebook unsafe or unable to run.

Use concise language for simple notebooks. Longer ingestion notebooks may use sections such as Overview, Processing Flow, Outputs, Scheduling, and Recovery Behavior.

### Opening Cell Template

```markdown
# <Notebook title>

## Overview

<Plain-English explanation of what the notebook does and why it exists.>

## Inputs and outputs

- Reads: `<source>`
- Writes: `<destination>`
- Attached Lakehouse: `<lakehouse>`

## Execution

<How it is run, expected frequency, retry/checkpoint behavior, and material prerequisites.>
```

## Parameters and Configuration

- Put runtime-adjustable values in a dedicated code cell immediately after the opening Markdown cell.
- Tag the cell `parameters` so Fabric pipelines can override values safely.
- Use descriptive uppercase names for constants, for example `MAX_RUNTIME_MINUTES`.
- Provide safe defaults and annotate units in the name or comment.
- Keep table names, batch sizes, lookback windows, and runtime ceilings together.
- Do not put imports, authentication calls, or processing logic in the parameters cell.
- Do not hardcode passwords, tokens, client secrets, API credentials, or connection strings. Store only secret names or approved connection references.

Environment-specific values should come from pipeline parameters, Fabric connections, an approved secret provider, or another documented configuration source.

## Imports and Runtime Setup

Use visible section dividers and group imports by origin. Keep imports at the top of the cell and remove duplicates and unused imports.

```python
# ==========================================================
# <System> → Microsoft Fabric Lakehouse
# <Notebook responsibility>
# ==========================================================

# Standard Library
import json
import time
from datetime import datetime, timezone

# Third Party
import requests

# Fabric / Spark
import notebookutils
from delta.tables import DeltaTable
from pyspark.sql import functions as F

# ==========================================================
# Authentication and Runtime Session
# ==========================================================
```

Additional requirements:

- Prefer supported `notebookutils` APIs over legacy `mssparkutils` imports in new work.
- Manage reusable libraries through a Fabric Environment rather than installing packages ad hoc in production notebooks.
- Initialize API sessions, retry policies, and common headers once.
- Fail early with a clear message when a required dependency or approved secret source is unavailable.
- Never print credentials or authentication headers.

## Visual Organization

Use consistent dividers for major sections inside code cells:

```python
# ==========================================================
# Incremental Window
# ==========================================================
```

Short comments should explain intent, constraints, or non-obvious decisions. Avoid comments that merely restate the next line of code. Use Markdown between major processing stages when readers need business context; use code comments for implementation-level structure.

## Data Engineering Behavior

- Use explicit schemas for stable production outputs whenever practical.
- Preserve raw source payloads when schema evolution or replay is important.
- Make scheduled writes idempotent. Prefer stable business keys with Delta `MERGE` or another documented deduplication strategy.
- Use bounded lookback windows for late-arriving changes when the source requires them.
- Add retry and backoff behavior for transient HTTP failures and throttling.
- Bound scheduled work with batch-size and runtime ceilings.
- Checkpoint long-running work so a later run can resume safely.
- Separate raw ingestion from downstream modeling and flattening unless there is a documented reason to combine them.
- Validate required tables, files, and attached Lakehouse context before processing.

## Validation and Observability

End scheduled notebooks with a concise run summary that includes the most useful available values:

- records selected, processed, inserted, updated, skipped, or rejected;
- output row counts or distinct-key checks;
- earliest and latest processed timestamps;
- checkpoint or remaining-backlog count;
- elapsed time and completion status.

Do not display raw records by default when they may contain personal, confidential, or credential data. Error messages should be actionable without including secrets or full sensitive payloads.

## Lakehouse and Fabric Metadata

- Attach the intended Lakehouse explicitly and confirm the target workspace before authoring or running the notebook.
- Preserve Fabric notebook metadata and cell structure during Git-backed edits.
- Treat the production workspace as read-only unless the user gives explicit, action-specific approval.
- Develop Git-connected changes in the development workspace and validate them there before promotion.
- Clear stale interactive outputs before committing notebooks to Git unless an output is intentionally retained as documentation.

## Naming

- Use descriptive lowercase `snake_case` notebook names, for example `orders_daily` and `inventory_snapshot`.
- Include the system or business domain and the notebook responsibility.
- Add cadence to the name only when cadence distinguishes the notebook's purpose, for example `orders_backfill_hourly`.
- Use consistent table constants such as `CALL_TABLE_NAME` and `TRANSCRIPT_TABLE_NAME` instead of repeating literals throughout the code.

## Review Checklist

Before a notebook is scheduled or promoted, confirm:

- [ ] The first cell is a plain-English Markdown overview.
- [ ] The parameters cell is tagged and contains no secrets.
- [ ] Imports are grouped and visually annotated.
- [ ] The attached workspace and Lakehouse are correct.
- [ ] Authentication uses an approved connection or secret provider.
- [ ] Writes are idempotent or their overwrite behavior is explicitly documented.
- [ ] Retries, rate limits, batch bounds, and runtime ceilings are appropriate.
- [ ] The final cell reports validation and operational results.
- [ ] Sensitive values and payloads are not printed or committed.
- [ ] Empty, duplicate, and temporary debugging cells have been removed.
- [ ] The smallest useful validation has passed in the intended non-production environment.

## Mandatory Pre-Publish Validation

Run the repository validator against the exact `.ipynb` definition that will be uploaded:

```bash
python3 scripts/validate-fabric-notebook.py <notebook.ipynb>
```

Every check must pass before creating, updating, or promoting a Fabric notebook. A successful Fabric REST API response confirms only that Fabric accepted the definition; it does not confirm that the notebook follows this standard. Record the validator result in the change closeout.

## Validator scope

The validator checks notebook structure, cleared outputs, and common literal credential assignments. It does not prove idempotency, retry behavior, data quality, or absence of all secrets. Review those properties for the actual workload. Delta merge, checkpoint function names, API call limits, and particular summary labels are implementation choices, not universal notebook requirements. Lakehouse binding is required only for workloads that use one; pass `--require-lakehouse` for that check.
