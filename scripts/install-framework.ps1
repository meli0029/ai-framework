[CmdletBinding()]
param(
    [switch]$FrameworkSkills,
    [switch]$Fabric,
    [switch]$FabricTools,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host "AI Framework Installer"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\scripts\install-framework.ps1 -FrameworkSkills"
    Write-Host "  .\scripts\install-framework.ps1 -Fabric"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -FrameworkSkills  Install this repository's reusable Codex skills"
    Write-Host "  -Fabric           Install official Microsoft Fabric skills (requires APM)"
    Write-Host "  -FabricTools      Install missing Fabric CLI prerequisites"
}

if ($Help -or (-not $FrameworkSkills -and -not $Fabric -and -not $FabricTools)) {
    Show-Help
    exit 0
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$skillsTarget = Join-Path $codexRoot "skills"

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target
    )
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Target -Recurse -Force
}

if ($FrameworkSkills) {
    $source = Join-Path $repoRoot "AI Framework\skills"
    Get-ChildItem -Path $source -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "SKILL.md")) {
            $target = Join-Path $skillsTarget $_.Name
            Copy-DirectoryContents -Source $_.FullName -Target $target
            Write-Host "Installed framework skill: $($_.Name)"
        }
    }
}

if ($FabricTools) {
    & (Join-Path $PSScriptRoot "bootstrap-fabric-tools.ps1") -Install
}

if ($Fabric) {
    if (-not (Get-Command apm -ErrorAction SilentlyContinue)) {
        throw "Microsoft APM is required. Install it using https://microsoft.github.io/apm/ and retry."
    }
    & apm install microsoft/skills-for-fabric --global --target codex --only apm --update
    if ($LASTEXITCODE -ne 0) { throw "Official Fabric skills installation failed." }
}

Write-Host "AI Framework installation complete."
