$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host " source-shared setup"
Write-Host "========================================"
Write-Host ""

$SourceSharedRoot = Split-Path -Parent $PSScriptRoot

$ProjectsConfig = Join-Path $SourceSharedRoot "config\projects.yaml"
$DeveloperConfig = Join-Path $SourceSharedRoot "config\developer.local.yaml"

Write-Host "Source repository:"
Write-Host "  $SourceSharedRoot"
Write-Host ""

$RequiredConfig = @(
    $ProjectsConfig,
    $DeveloperConfig
)

foreach ($File in $RequiredConfig) {
    if (-not (Test-Path $File)) {
        Write-Host "ERROR: Required file not found:" -ForegroundColor Red
        Write-Host "  $File" -ForegroundColor Red
        exit 1
    }
}

$Skills = @(
    "start-ticket",
    "implement-ticket"
)

foreach ($SkillName in $Skills) {
    $SkillSource = Join-Path $SourceSharedRoot "skills\$SkillName"
    $SkillFile = Join-Path $SkillSource "SKILL.md"

    if (-not (Test-Path $SkillFile)) {
        Write-Host "ERROR: Missing SKILL.md for $SkillName" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Required files: OK" -ForegroundColor Green
Write-Host ""

$CodexSkillsRoot = Join-Path $HOME ".agents\skills"
$ClaudeSkillsRoot = Join-Path $HOME ".claude\skills"

function Install-SharedSkill {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SkillName,

        [Parameter(Mandatory = $true)]
        [string]$SkillsRoot,

        [Parameter(Mandatory = $true)]
        [string]$ClientName
    )

    $SkillSource = Join-Path $SourceSharedRoot "skills\$SkillName"
    $Destination = Join-Path $SkillsRoot $SkillName

    Write-Host "Installing $SkillName for $ClientName..."

    if (-not (Test-Path $SkillsRoot)) {
        New-Item -ItemType Directory -Path $SkillsRoot -Force | Out-Null
    }

    if (Test-Path $Destination) {
        Remove-Item $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    Copy-Item `
        -Path (Join-Path $SkillSource "*") `
        -Destination $Destination `
        -Recurse `
        -Force

    $ReferencesDirectory = Join-Path $Destination "references"

    New-Item `
        -ItemType Directory `
        -Path $ReferencesDirectory `
        -Force | Out-Null

    Copy-Item `
        -Path $ProjectsConfig `
        -Destination (Join-Path $ReferencesDirectory "projects.yaml") `
        -Force

    Copy-Item `
        -Path $DeveloperConfig `
        -Destination (Join-Path $ReferencesDirectory "developer.local.yaml") `
        -Force

    Write-Host "  Installed: $Destination" -ForegroundColor Green
}

foreach ($SkillName in $Skills) {

    Install-SharedSkill `
        -SkillName $SkillName `
        -SkillsRoot $CodexSkillsRoot `
        -ClientName "Codex"

    Install-SharedSkill `
        -SkillName $SkillName `
        -SkillsRoot $ClaudeSkillsRoot `
        -ClientName "Claude Code"

    Write-Host ""
}

Write-Host "========================================"
Write-Host " Setup complete"
Write-Host "========================================"
Write-Host ""

Write-Host "Installed skills:"
foreach ($SkillName in $Skills) {
    Write-Host "  - $SkillName"
}

Write-Host ""
Write-Host "Codex skills root:"
Write-Host "  $CodexSkillsRoot"

Write-Host ""
Write-Host "Claude Code skills root:"
Write-Host "  $ClaudeSkillsRoot"

Write-Host ""
Write-Host "Developer configuration copied from:"
Write-Host "  $DeveloperConfig"

Write-Host ""
Write-Host "Commands:"
Write-Host '  Codex: $start-ticket KDV-22'
Write-Host '  Codex: $implement-ticket KDV-22'
Write-Host '  Claude: /start-ticket KDV-22'
Write-Host '  Claude: /implement-ticket KDV-22'
Write-Host ""