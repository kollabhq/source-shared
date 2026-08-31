$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host " source-shared setup"
Write-Host "========================================"
Write-Host ""

# ------------------------------------------------------------
# Resolve source-shared repository
# ------------------------------------------------------------

$SourceSharedRoot = Split-Path -Parent $PSScriptRoot

$SkillSource = Join-Path $SourceSharedRoot "skills\start-ticket"
$ProjectsConfig = Join-Path $SourceSharedRoot "config\projects.yaml"
$DeveloperConfig = Join-Path $SourceSharedRoot "config\developer.local.yaml"

Write-Host "Source repository:"
Write-Host "  $SourceSharedRoot"
Write-Host ""

# ------------------------------------------------------------
# Validate required files
# ------------------------------------------------------------

$RequiredFiles = @(
    (Join-Path $SkillSource "SKILL.md"),
    (Join-Path $SkillSource "assets\analysis-template.md"),
    (Join-Path $SkillSource "assets\checklist-template.md"),
    $ProjectsConfig,
    $DeveloperConfig
)

foreach ($File in $RequiredFiles) {
    if (-not (Test-Path $File)) {
        Write-Host "ERROR: Required file not found:" -ForegroundColor Red
        Write-Host "  $File" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

Write-Host "Required files: OK" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# Destination paths
# ------------------------------------------------------------

$CodexSkillsRoot = Join-Path $HOME ".agents\skills"
$ClaudeSkillsRoot = Join-Path $HOME ".claude\skills"

$CodexDestination = Join-Path $CodexSkillsRoot "start-ticket"
$ClaudeDestination = Join-Path $ClaudeSkillsRoot "start-ticket"

# ------------------------------------------------------------
# Helper function
# ------------------------------------------------------------

function Install-StartTicketSkill {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [Parameter(Mandatory = $true)]
        [string]$ClientName
    )

    Write-Host "Installing start-ticket for $ClientName..."

    # Ensure parent skill directory exists.
    $ParentDirectory = Split-Path -Parent $Destination

    if (-not (Test-Path $ParentDirectory)) {
        New-Item -ItemType Directory -Path $ParentDirectory -Force | Out-Null
    }

    # Replace only our own installed skill.
    # Never modify other skills.
    if (Test-Path $Destination) {
        Remove-Item $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    # Copy the shared skill.
    Copy-Item `
        -Path (Join-Path $SkillSource "*") `
        -Destination $Destination `
        -Recurse `
        -Force

    # Runtime config travels with the installed skill.
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

# ------------------------------------------------------------
# Install Codex skill
# ------------------------------------------------------------

Install-StartTicketSkill `
    -Destination $CodexDestination `
    -ClientName "Codex"

Write-Host ""

# ------------------------------------------------------------
# Install Claude skill
# ------------------------------------------------------------

Install-StartTicketSkill `
    -Destination $ClaudeDestination `
    -ClientName "Claude Code"

Write-Host ""

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host "========================================"
Write-Host " Setup complete"
Write-Host "========================================"
Write-Host ""

Write-Host "Codex:"
Write-Host "  $CodexDestination"
Write-Host ""

Write-Host "Claude Code:"
Write-Host "  $ClaudeDestination"
Write-Host ""

Write-Host "Developer configuration copied from:"
Write-Host "  $DeveloperConfig"
Write-Host ""

Write-Host "IMPORTANT:"
Write-Host "  Re-run this setup script whenever shared"
Write-Host "  skill files or local developer config change."
Write-Host ""

Write-Host "Next Codex test:"
Write-Host '  $start-ticket KDV-22'
Write-Host ""