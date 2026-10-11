# Contributing reusable improvements

Keep the framework checkout and client checkout as sibling Git repositories. They may share an editor workspace, but each keeps its own remote, branch, and commits.

1. Implement and validate client work in the client repository.
2. Extract a reusable improvement into a branch based on this repository's current default branch.
3. Replace client identifiers and business assumptions with parameters or placeholders. Include the tests and documentation needed to use the extracted feature.
4. Review `git diff --cached` before committing and open a focused PR here. Do not merge a client's complete history into this repository.
5. After review, have client projects consume the selected framework revision through the installer workflow. Record the chosen revision in the client repository when reproducibility is needed.

## What belongs here

| Framework | Client implementation | Local output |
|---|---|---|
| Generic skills and installers | Pipelines and notebooks bound to client systems | Temporary exports |
| Reusable validators and their tests | Business logic and its tests | Caches and scratch experiments |
| Standards and parameterized templates | Tenant/workspace registries and operational runbooks | Generated diagnostic logs |
| Sanitized, maintained examples | Intentionally retained deployment evidence | Credentials: never commit |

Classify by purpose, not extension. A Python test can belong in either repository. Store knowledge in `AI Framework/knowledge`, tasks in `skills`, workflows in `playbooks`, conventions in `standards`, starting points in `templates`, and maintained reference implementations in `examples`.

Vendor tools remain external dependencies. Use their supported installers; do not copy vendor implementations into this tree. Configure an agent or MCP server only when the user explicitly requests it.

Use `scratch/` for ignored local experiments. Important client source and evidence should be versioned in the client repository, not hidden indefinitely with ignore rules. Ignore rules do not untrack files already committed.

## Validation

Run Bash syntax checks for changed shell scripts, skill frontmatter validation when available, and `python3 -m unittest discover -s tests`. Test installer routing with temporary destinations or mocked commands; ordinary contribution checks must not install software or mutate Fabric. Report platforms and live integrations that were not tested.
