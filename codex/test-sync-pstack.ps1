param(
    [Parameter(Mandatory)][string]$SourceRoot,
    [Parameter(Mandatory)][string]$TestRoot
)

$ErrorActionPreference = 'Stop'
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$TestRoot = [IO.Path]::GetFullPath($TestRoot)
if (Test-Path -LiteralPath $TestRoot) { throw "Use a new test directory: $TestRoot" }
$profileRoot = Join-Path $TestRoot 'profile'
$codexHome = Join-Path $profileRoot '.codex'
$skillsRoot = Join-Path $profileRoot '.agents\skills'
$legacyTarget = Join-Path $TestRoot 'official\cursor-plugins\pstack\0.15.36\skills\poteto-mode'
$legacyLink = Join-Path $codexHome 'skills\poteto-mode'
$pstackHome = Join-Path $codexHome 'pstack'
$collision = Join-Path $skillsRoot 'how'
$installer = Join-Path $SourceRoot 'codex\sync-pstack.ps1'
$utf8 = New-Object Text.UTF8Encoding $false

function Assert-Condition([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
}

New-Item -ItemType Directory -Path $legacyTarget, (Split-Path $legacyLink -Parent), $pstackHome, $skillsRoot -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $legacyTarget 'sentinel.txt'), 'official content', $utf8)
New-Item -ItemType Junction -Path $legacyLink -Target $legacyTarget | Out-Null
$originalAgents = "Keep my personal instructions.`n`nBefore following any pstack skill, read`n~/.codex/pstack/codex-adapter.md in place of its Claude Code adapter.`n"
[IO.File]::WriteAllText((Join-Path $codexHome 'AGENTS.md'), $originalAgents, $utf8)
[IO.File]::WriteAllText((Join-Path $pstackHome 'codex-adapter.md'), 'legacy integration', $utf8)
[IO.File]::WriteAllText((Join-Path $pstackHome 'pstack-delegate.ps1'), 'legacy delegate', $utf8)
foreach ($collisionKind in @('Directory', 'File')) {
    New-Item -ItemType $collisionKind -Path $collision | Out-Null
    $rejected = $false
    try { & $installer -SourceRoot $SourceRoot -CodexHome $codexHome -SkillsRoot $skillsRoot } catch {
        if ($_.Exception.Message -notlike 'An unrelated skill already owns*') { throw }
        $rejected = $true
    }
    Assert-Condition $rejected "A conflicting user $collisionKind stops installation."
    Assert-Condition (@((Get-Item -LiteralPath $legacyLink).Target)[0] -eq $legacyTarget) 'Conflict preserves the old link.'
    Assert-Condition ([IO.File]::ReadAllText((Join-Path $codexHome 'AGENTS.md')) -eq $originalAgents) 'Conflict preserves personal instructions.'
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pstackHome 'versions'))) 'Conflict creates no runtime.'
    Move-Item -LiteralPath $collision -Destination (Join-Path $TestRoot "saved-user-$collisionKind")
}
Write-Output 'PASS: conflicting directories and files leave the profile unchanged.'

& $installer -SourceRoot $SourceRoot -CodexHome $codexHome -SkillsRoot $skillsRoot
$installed = Get-Content -LiteralPath (Join-Path $pstackHome 'install.json') -Raw | ConvertFrom-Json
$sourceNames = @(Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'pstack\skills') -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') }).Name
Assert-Condition ($installed.skillNames.Count -eq $sourceNames.Count) 'Every source skill is installed.'
foreach ($name in $sourceNames) {
    $skillPath = Join-Path $skillsRoot "$name\SKILL.md"
    Assert-Condition (Test-Path -LiteralPath $skillPath) "The skill $name is readable through its installed link."
    Assert-Condition ([IO.File]::ReadAllText($skillPath).Contains('[Codex runtime](../../docs/harness/codex.md)')) "The skill $name loads the native runtime."
}
Assert-Condition (-not (Test-Path -LiteralPath $legacyLink)) 'The legacy discovery link is removed.'
Assert-Condition ([IO.File]::ReadAllText((Join-Path $legacyTarget 'sentinel.txt')) -eq 'official content') 'Migration does not alter the old target.'
Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pstackHome 'codex-adapter.md'))) 'The old adapter is no longer active.'
Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $installed.versionRoot 'docs\harness\claude-code.md'))) 'The runtime contains no Claude adapter.'
Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $installed.versionRoot 'docs\guide'))) 'Historical platform setup guides are not active.'
foreach ($match in [regex]::Matches([IO.File]::ReadAllText((Join-Path $installed.versionRoot 'README.md')), '\]\(([^)]+)\)')) {
    Assert-Condition (Test-Path -LiteralPath (Join-Path $installed.versionRoot $match.Groups[1].Value)) 'Installed README links resolve.'
}
Assert-Condition (Test-Path -LiteralPath (Join-Path $installed.backupRoot 'codex-adapter.md')) 'The previous adapter can be recovered.'
$agents = [IO.File]::ReadAllText((Join-Path $codexHome 'AGENTS.md'))
Assert-Condition ($agents.StartsWith('Keep my personal instructions.')) 'Personal instructions remain intact.'
Assert-Condition (-not $agents.Contains('codex-adapter.md')) 'Global instructions route to the native runtime.'
$visual = 'skills\poteto-mode\references\visual-design.md'
Assert-Condition ((Get-FileHash -LiteralPath (Join-Path $SourceRoot "pstack\$visual")).Hash -eq (Get-FileHash -LiteralPath (Join-Path $installed.versionRoot $visual)).Hash) 'The visual guidance matches its source.'
Write-Output 'PASS: all skills migrate to a standalone runtime with recovery copies.'

$modelsPath = Join-Path $pstackHome 'pstack-models.md'
[IO.File]::AppendAllText($modelsPath, "`n# keep my local model choice`n", $utf8)
$modelsHash = (Get-FileHash -LiteralPath $modelsPath).Hash
$firstRuntime = $installed.versionRoot
$keepSkill = Join-Path $skillsRoot 'unrelated-skill'
New-Item -ItemType Directory -Path $keepSkill -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $keepSkill 'sentinel.txt'), 'keep', $utf8)
& $installer -SourceRoot $SourceRoot -CodexHome $codexHome -SkillsRoot $skillsRoot
$installed = Get-Content -LiteralPath (Join-Path $pstackHome 'install.json') -Raw | ConvertFrom-Json
Assert-Condition ((Get-FileHash -LiteralPath $modelsPath).Hash -eq $modelsHash) 'Reinstall preserves local model choices.'
Assert-Condition (Test-Path -LiteralPath $firstRuntime) 'The previous runtime remains recoverable.'
Assert-Condition ([IO.File]::ReadAllText((Join-Path $keepSkill 'sentinel.txt')) -eq 'keep') 'An unrelated skill is unchanged.'
Assert-Condition (([regex]::Matches([IO.File]::ReadAllText((Join-Path $codexHome 'AGENTS.md')), '<!-- pstack:begin -->')).Count -eq 1) 'Reinstall keeps one pstack instruction block.'
Assert-Condition (Test-Path -LiteralPath (Join-Path $skillsRoot 'poteto-mode\SKILL.md')) 'The reinstalled runtime is readable.'
Write-Output 'PASS: reinstall preserves model choices, unrelated skills, and the previous version.'
