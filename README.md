# AI Framework

Reusable engineering skills, standards, playbooks, templates, and vendor installation helpers. Client implementations belong in separate repositories.

See the [framework overview](AI%20Framework/README.md) and [contribution boundaries](CONTRIBUTING.md).

## Workstation setup

```bash
./scripts/install-framework.sh --framework-skills
./scripts/bootstrap-fabric-tools.sh --check
# When Fabric CLI prerequisites are needed:
./scripts/install-framework.sh --fabric-tools
# Requires Microsoft's APM CLI; installs official skills, without MCP registration:
./scripts/install-framework.sh --fabric
```

On native Windows:

```powershell
.\scripts\install-framework.ps1 -FrameworkSkills
.\scripts\bootstrap-fabric-tools.ps1 -Check
.\scripts\install-framework.ps1 -FabricTools
.\scripts\install-framework.ps1 -Fabric
```

Framework skills are installed into `${CODEX_HOME:-$HOME/.codex}/skills`. Installing them copies instructions; it does not execute their workflows. Official Fabric skills use [Microsoft's APM installation method](https://github.com/microsoft/skills-for-fabric), in user scope with MCP configuration disabled. Install [APM](https://microsoft.github.io/apm/) separately before using `--fabric` / `-Fabric`. Existing manually copied vendor skills are not removed automatically; use the vendor's migration guidance if duplicates remain.

## Available extensions

- `install-claude-code`: official CLI installation and troubleshooting; optional, explicitly requested Fabric MCP setup.
- `onboard-fabric-user`: workstation checks, interactive tenant authentication, and read-only workspace verification using the client repository's configuration.
- `install-wsl-browser-bridge`: diagnose and repair browser opening under WSL.
- `configure-sudo-cache`: diagnose sudo timestamp reuse and configure a bounded, user-scoped policy when requested.

The Claude helper uses [Anthropic's native installer](https://code.claude.com/docs/en/setup). No agent settings, MCP server definitions, cloud resources, or authentication sessions are changed by merely installing the framework skills.

## Fabric guidance

- [Onboarding playbook](AI%20Framework/playbooks/fabric-workstation-onboarding.md)
- [Change control](AI%20Framework/standards/fabric/change-control.md)
- [Notebook development](AI%20Framework/standards/fabric/notebook-development.md)
- [Secret handling](AI%20Framework/standards/security-and-secret-handling.md)
- [Environment template](AI%20Framework/templates/fabric/fabric.env.example)

Validate a proposed notebook locally:

```bash
python3 scripts/validate-fabric-notebook.py path/to/notebook.ipynb
# For notebooks requiring an attached Lakehouse:
python3 scripts/validate-fabric-notebook.py path/to/notebook.ipynb --require-lakehouse
python3 -m unittest discover -s tests
```

The validator is a structural check, not a substitute for workload review or development-workspace testing.
