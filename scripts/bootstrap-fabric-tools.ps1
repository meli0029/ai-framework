[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Install
)

$ErrorActionPreference = "Stop"

if ($Check -and $Install) {
    throw "Choose either -Check or -Install, not both."
}
if (-not $Check -and -not $Install) {
    $Check = $true
}

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Update-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

$requirements = @(
    @{ Name = "Git"; Commands = @("git"); WingetId = "Git.Git" },
    @{ Name = "Python 3"; Commands = @("python", "py"); WingetId = "Python.Python.3.13" },
    @{ Name = "Azure CLI"; Commands = @("az"); WingetId = "Microsoft.AzureCLI" },
    @{ Name = "Go sqlcmd"; Commands = @("sqlcmd"); WingetId = "Microsoft.Sqlcmd" }
)

function Test-Requirement {
    param([Parameter(Mandatory)][hashtable]$Requirement)
    foreach ($command in $Requirement.Commands) {
        if (Test-Command $command) {
            return $true
        }
    }
    return $false
}

function Show-Status {
    $missing = @()
    Write-Host "Checking Fabric CLI workstation prerequisites..."
    foreach ($requirement in $requirements) {
        if (Test-Requirement $requirement) {
            Write-Host ("OK       {0}" -f $requirement.Name)
        }
        else {
            Write-Host ("MISSING  {0}" -f $requirement.Name)
            $missing += $requirement
        }
    }

    if (Test-Command "az") {
        $azVersion = az version --query '"azure-cli"' --output tsv 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Host "VERSION  az $azVersion" }
    }
    if (Test-Command "sqlcmd") {
        $sqlcmdVersion = sqlcmd --version 2>$null | Select-Object -First 1
        if ($sqlcmdVersion) { Write-Host "VERSION  $sqlcmdVersion" }
    }

    return $missing
}

if ($Install) {
    if (-not (Test-Command "winget")) {
        throw "WinGet is required. Install or update Microsoft App Installer, then rerun this script."
    }

    $missing = @(Show-Status)
    foreach ($requirement in $missing) {
        Write-Host ("Installing {0} ({1})..." -f $requirement.Name, $requirement.WingetId)
        & winget install --exact --id $requirement.WingetId --source winget `
            --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "WinGet failed while installing $($requirement.Name)."
        }
        Update-ProcessPath
    }
    Write-Host ""
}

$remaining = @(Show-Status)
if ($remaining.Count -gt 0) {
    if ($Check) {
        Write-Host "Review the missing tools, then rerun with -Install if appropriate."
    }
    exit 1
}

Write-Host "All required command-line tools are available."
