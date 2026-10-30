# Points every pstack skill in ~/.codex/skills at the copy Claude Code loads, so Claude Code,
# Codex CLI, and the ChatGPT desktop app read the same files. Safe to rerun; rerun after a pstack update.
$ErrorActionPreference = 'Stop'

$installed = Get-Content (Join-Path $HOME '.claude\plugins\installed_plugins.json') -Raw | ConvertFrom-Json
$pstackRoot = ($installed.plugins.'pstack@cursor-plugins' | Select-Object -First 1).installPath
$source = Join-Path $pstackRoot 'skills'
$dest = Join-Path $HOME '.codex\skills'
$want = @{}
Get-ChildItem $source -Directory | ForEach-Object { $want[$_.Name] = $_.FullName }

function Get-JunctionTarget($path) {
    $item = Get-Item -LiteralPath $path -Force
    if ($item.LinkType -ne 'Junction') { return $null }
    return @($item.Target)[0]
}

$removed = 0
Get-ChildItem $dest -Directory -Force | ForEach-Object {
    $target = Get-JunctionTarget $_.FullName
    if ($target -and $target -like '*\cursor-plugins\pstack\*' -and $want[$_.Name] -ne $target) {
        [System.IO.Directory]::Delete($_.FullName, $false)
        $removed++
    }
}

$created = 0; $kept = 0
foreach ($name in $want.Keys | Sort-Object) {
    $link = Join-Path $dest $name
    if (Test-Path -LiteralPath $link) {
        if ((Get-JunctionTarget $link) -eq $want[$name]) { $kept++; continue }
        throw "$link exists and is not a pstack junction. Move it aside, then rerun."
    }
    New-Item -ItemType Junction -Path $link -Target $want[$name] | Out-Null
    $created++
}

"pstack $pstackRoot"
"skills: $($want.Count) total, $created created, $kept kept, $removed stale removed"
