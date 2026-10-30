# Runs one pstack delegate in a visible herdr tab and prints its report.
# codex = execution roles (GPT-6.1 Sol high). claude = design and judgment roles (Opus 5.5 medium).
# Run with: powershell -NoProfile -ExecutionPolicy Bypass -File pstack-delegate.ps1 -Kind codex -Name fixer -Repo <dir> -Brief <file>
param(
    [Parameter(Mandatory)][ValidateSet('codex', 'claude')][string]$Kind,
    [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9_-]{0,31}$')][string]$Name,
    [Parameter(Mandatory)][string]$Repo,
    [Parameter(Mandatory)][string]$Brief,
    [ValidateSet('read-only', 'write')][string]$Mode = 'read-only',
    [int]$TimeoutMinutes = 60,
    [switch]$Keep
)
$ErrorActionPreference = 'Continue'

function Invoke-HerdrJson { $out = & herdr.exe @args; if ($LASTEXITCODE) { throw "herdr $args failed: $out" }; $out | ConvertFrom-Json }

$Repo = (Resolve-Path $Repo).Path
$Brief = (Resolve-Path $Brief).Path
$outDir = Join-Path $env:TEMP 'pstack-delegate'
New-Item -ItemType Directory -Force $outDir | Out-Null
$result = Join-Path $outDir "$Name-$(Get-Date -Format yyyyMMddHHmmss).md"

$launch = @{
    codex  = "codex.cmd -m gpt-6.1-sol -c model_reasoning_effort=high -s workspace-write -a never -C `"$Repo`" --add-dir `"$outDir`" --add-dir `"$(Split-Path $Brief)`""
    claude = "claude --model opus --effort medium --permission-mode auto --add-dir `"$outDir`" --add-dir `"$(Split-Path $Brief)`""
}[$Kind]
$scope = if ($Mode -eq 'read-only') { 'Inspect only. Do not modify any file except the report file.' } else { 'You may edit files inside the repository.' }
$prompt = "Read $Brief and do that task in $Repo. $scope When finished, write your final report to $result."

$tab = Invoke-HerdrJson tab create --cwd $Repo --label "pstack-$Name" --no-focus
$pane = $tab.result.root_pane.pane_id
& herdr pane run $pane $launch | Out-Null

$deadline = (Get-Date).AddSeconds(90)
while ($true) {
    & herdr agent rename $pane $Name 2>$null | Out-Null
    if (-not $LASTEXITCODE) { break }
    if ((Get-Date) -gt $deadline) { throw "$Kind did not start in pane $pane. Inspect it with: herdr pane read $pane --lines 40" }
    Start-Sleep -Seconds 2
}
& herdr agent wait $Name --until idle --until done --timeout 90000 | Out-Null
# A freshly started TUI can drop the first submission. A stalled prompt never reached the input, so resending is safe.
foreach ($attempt in 1..3) {
    $sent = & herdr agent prompt $Name $prompt --wait --timeout ($TimeoutMinutes * 60000) 2>&1 | Out-String
    if ($sent -notmatch 'agent_prompt_stalled') { break }
    Start-Sleep -Seconds 3
}

$state = (Invoke-HerdrJson agent get $Name).result.agent.agent_status
if (-not (Test-Path $result)) {
    "No report from $Name (status $state). Pane $pane is left open for inspection."
    exit 1
}
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Get-Content $result -Raw -Encoding UTF8
if ($Mode -eq 'read-only' -and (Test-Path (Join-Path $Repo '.git'))) { git -C $Repo status --short }
if (-not $Keep) { & herdr tab close $tab.result.tab.tab_id | Out-Null }
