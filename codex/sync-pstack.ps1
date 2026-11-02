param(
    [Parameter(Mandatory)][string]$SourceRoot,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$SkillsRoot = (Join-Path $HOME '.agents\skills')
)

$ErrorActionPreference = 'Stop'
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$CodexHome = [IO.Path]::GetFullPath($CodexHome)
$SkillsRoot = [IO.Path]::GetFullPath($SkillsRoot)
$source = Join-Path $SourceRoot 'pstack'
$integration = Join-Path $SourceRoot 'codex'
$pstackHome = Join-Path $CodexHome 'pstack'
$legacySkills = Join-Path $CodexHome 'skills'
$runtimeLink = Join-Path $pstackHome 'runtime'
$utf8 = New-Object Text.UTF8Encoding $false

foreach ($required in @('pstack\skills\poteto-mode\SKILL.md', 'codex\runtime.md', 'codex\rules\pstack-models.md', 'codex\guide\agents-block.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $SourceRoot $required) -PathType Leaf)) {
        throw "Not a pstack-codex source checkout: $SourceRoot (missing $required)"
    }
}
if ($SkillsRoot -eq $legacySkills -or $SkillsRoot.StartsWith($pstackHome + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'SkillsRoot must be separate from the legacy skill directory and the pstack runtime.'
}
$skills = @(Get-ChildItem -LiteralPath (Join-Path $source 'skills') -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') })
$names = @($skills.Name)
$oldLinks = @()
foreach ($directory in @($SkillsRoot, $legacySkills)) {
    if (-not (Test-Path -LiteralPath $directory)) { continue }
    foreach ($item in Get-ChildItem -LiteralPath $directory -Force) {
        $target = @($item.Target)[0]
        $owned = $item.LinkType -eq 'Junction' -and ($target -like '*\cursor-plugins\pstack\*\skills\*' -or $target.StartsWith($pstackHome + '\', [StringComparison]::OrdinalIgnoreCase))
        if ($owned) {
            $oldLinks += [pscustomobject]@{ path = $item.FullName; target = $target }
        } elseif ($names -contains $item.Name) {
            throw "An unrelated skill already owns $($item.FullName). No installation changes were made."
        }
    }
}
if (Test-Path -LiteralPath $runtimeLink) {
    $runtimeItem = Get-Item -LiteralPath $runtimeLink -Force
    if ($runtimeItem.LinkType -ne 'Junction' -or -not @($runtimeItem.Target)[0].StartsWith((Join-Path $pstackHome 'versions') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "The runtime path is not a managed pstack junction: $runtimeLink"
    }
}

$installId = (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
$versionRoot = Join-Path (Join-Path $pstackHome 'versions') $installId
$backupRoot = Join-Path (Join-Path $pstackHome 'backups') $installId
New-Item -ItemType Directory -Path $versionRoot, $backupRoot, $SkillsRoot -Force | Out-Null
foreach ($file in Get-ChildItem -LiteralPath $source -Recurse -File) {
    $relative = $file.FullName.Substring($source.Length + 1)
    if ($relative -notlike 'skills\*' -and $relative -notlike 'agents\*' -and $relative -ne 'LICENSE') { continue }
    $destination = Join-Path $versionRoot $relative
    New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destination
}
$overrides = Join-Path $integration 'skills'
foreach ($file in Get-ChildItem -LiteralPath $overrides -Recurse -File) {
    $relative = $file.FullName.Substring($overrides.Length + 1)
    Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $versionRoot "skills\$relative") -Force
}
New-Item -ItemType Directory -Path (Join-Path $versionRoot 'docs\harness') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $integration 'runtime.md') -Destination (Join-Path $versionRoot 'docs\harness\codex.md')
$runtimeReadme = "# pstack for Codex`n`nRead [Codex runtime](docs/harness/codex.md). The [installation record](../../install.json) identifies the source checkout and skill paths.`n"
[IO.File]::WriteAllText((Join-Path $versionRoot 'README.md'), $runtimeReadme, $utf8)
$frontmatter = New-Object Text.RegularExpressions.Regex '(?s)\A---\r?\n.*?\r?\n---\r?\n'
foreach ($name in $names) {
    $skillFile = Join-Path $versionRoot "skills\$name\SKILL.md"
    $text = [IO.File]::ReadAllText($skillFile)
    $notice = "`nRead [Codex runtime](../../docs/harness/codex.md) before following this skill. Its platform and model rules take precedence over upstream platform examples.`n"
    $text = $frontmatter.Replace($text, ('$0' + $notice), 1)
    [IO.File]::WriteAllText($skillFile, $text, $utf8)
}

$agentsPath = Join-Path $CodexHome 'AGENTS.md'
$agents = if (Test-Path -LiteralPath $agentsPath) { [IO.File]::ReadAllText($agentsPath) } else { '' }
$block = [IO.File]::ReadAllText((Join-Path $integration 'guide\agents-block.txt')).Trim()
$legacyBlock = 'Before following any pstack skill, read\s+~/.codex/pstack/codex-adapter\.md in place of its Claude Code adapter\.'
if ($agents -match '(?s)<!-- pstack:begin -->.*?<!-- pstack:end -->') {
    $agents = [regex]::Replace($agents, '(?s)<!-- pstack:begin -->.*?<!-- pstack:end -->', [Text.RegularExpressions.MatchEvaluator]{ param($match) $block })
} elseif ($agents -match $legacyBlock) {
    $agents = [regex]::Replace($agents, $legacyBlock, [Text.RegularExpressions.MatchEvaluator]{ param($match) $block })
} else {
    $agents = $agents.TrimEnd() + "`n`n" + $block + "`n"
}
if (Test-Path -LiteralPath $agentsPath) { Copy-Item -LiteralPath $agentsPath -Destination (Join-Path $backupRoot 'AGENTS.md') }
[IO.File]::WriteAllText((Join-Path $backupRoot 'junctions.json'), (ConvertTo-Json -InputObject $oldLinks -Depth 4), $utf8)
foreach ($oldName in @('codex-adapter.md', 'pstack-delegate.ps1', 'sync-pstack.ps1', 'guide', 'install.json', 'runtime.md')) {
    $oldPath = [IO.Path]::GetFullPath((Join-Path $pstackHome $oldName))
    if (-not $oldPath.StartsWith($pstackHome + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Invalid backup path: $oldPath" }
    if (Test-Path -LiteralPath $oldPath) { Move-Item -LiteralPath $oldPath -Destination (Join-Path $backupRoot $oldName) }
}
if (Test-Path -LiteralPath $runtimeLink) {
    [IO.File]::WriteAllText((Join-Path $backupRoot 'runtime-target.txt'), @((Get-Item -LiteralPath $runtimeLink -Force).Target)[0], $utf8)
    [IO.Directory]::Delete($runtimeLink, $false)
}
New-Item -ItemType Junction -Path $runtimeLink -Target $versionRoot | Out-Null
foreach ($link in $oldLinks) { [IO.Directory]::Delete($link.path, $false) }
foreach ($name in $names) {
    New-Item -ItemType Junction -Path (Join-Path $SkillsRoot $name) -Target (Join-Path $runtimeLink "skills\$name") | Out-Null
}
$modelsPath = Join-Path $pstackHome 'pstack-models.md'
if (-not (Test-Path -LiteralPath $modelsPath)) {
    Copy-Item -LiteralPath (Join-Path $integration 'rules\pstack-models.md') -Destination $modelsPath
}
Copy-Item -LiteralPath (Join-Path $integration 'runtime.md') -Destination (Join-Path $pstackHome 'runtime.md')
Copy-Item -LiteralPath (Join-Path $integration 'sync-pstack.ps1') -Destination (Join-Path $pstackHome 'sync-pstack.ps1')
[IO.File]::WriteAllText($agentsPath, $agents, $utf8)
$installation = [ordered]@{ sourceRoot = $SourceRoot; versionRoot = $versionRoot; skillsRoot = $SkillsRoot; skillNames = $names; backupRoot = $backupRoot }
[IO.File]::WriteAllText((Join-Path $pstackHome 'install.json'), ($installation | ConvertTo-Json -Depth 4), $utf8)
"Installed $($names.Count) pstack skills for Codex."
"Runtime: $versionRoot"
"Recovery: $backupRoot"
