$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-HookLog {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  $entry = "{0} {1}" -f (Get-Date -Format o), $Message
  [System.IO.File]::AppendAllText($script:HookLogPath, $entry + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
}

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $output = & git @Arguments 2>&1
  $exitCode = $LASTEXITCODE
  $text = if ($null -eq $output) {
    ''
  }
  elseif ($output -is [string]) {
    $output
  }
  else {
    ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
  }

  [pscustomobject]@{
    ExitCode = $exitCode
    Output   = $text.TrimEnd()
  }
}

function Emit-Json {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Payload
  )

  [Console]::Out.WriteLine(($Payload | ConvertTo-Json -Compress))
}

$stdinText = [Console]::In.ReadToEnd()
$payload = $null
if (-not [string]::IsNullOrWhiteSpace($stdinText)) {
  try {
    $payload = $stdinText | ConvertFrom-Json -ErrorAction Stop
  }
  catch {
    $payload = $null
  }
}

$repoRootResult = Invoke-Git -Arguments @('rev-parse', '--show-toplevel')
if ($repoRootResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($repoRootResult.Output)) {
  Emit-Json @{ continue = $true }
  exit 0
}

$permissionMode = $null
if ($null -ne $payload -and $payload.PSObject.Properties.Name -contains 'permission_mode') {
  $permissionMode = [string]$payload.permission_mode
}

$script:RepoRoot = $repoRootResult.Output
$script:HookLogPath = Join-Path $script:RepoRoot '.codex\hooks\hook.log'
$script:IndexPath = Join-Path $script:RepoRoot 'index.html'

$null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $script:HookLogPath)

Write-HookLog "start permission_mode=$permissionMode repo_root=$script:RepoRoot"

if ($permissionMode -ieq 'plan') {
  Write-HookLog 'decision=continue reason=permission_mode_plan'
  Emit-Json @{ continue = $true }
  exit 0
}

$statusResult = Invoke-Git -Arguments @('status', '--porcelain', '--', 'index.html')
Write-HookLog ("git status exit={0} output=`"{1}`"" -f $statusResult.ExitCode, $statusResult.Output)
if ($statusResult.ExitCode -ne 0) {
  Write-HookLog 'decision=continue reason=git_status_failed'
  Emit-Json @{ continue = $true }
  exit 0
}

if ([string]::IsNullOrWhiteSpace($statusResult.Output)) {
  Write-HookLog 'decision=continue reason=index_html_unchanged'
  Emit-Json @{ continue = $true }
  exit 0
}

if (-not (Test-Path -LiteralPath $script:IndexPath)) {
  Write-HookLog 'decision=blocked reason=index_html_deleted_or_missing'
  Emit-Json @{ continue = $false; reason = 'BLOCKED: index.html is deleted or missing' }
  exit 0
}

$indexContent = Get-Content -LiteralPath $script:IndexPath -Raw
$hasHtml = $indexContent -match '(?is)<html'
$hasHead = $indexContent -match '(?is)<head'
$hasBody = $indexContent -match '(?is)<body'
Write-HookLog ("content_check html={0} head={1} body={2}" -f $hasHtml, $hasHead, $hasBody)
if (-not ($hasHtml -and $hasHead -and $hasBody)) {
  Write-HookLog 'decision=blocked reason=index_html_missing_required_tags'
  Emit-Json @{ continue = $false; reason = 'BLOCKED: index.html must include <html, <head, and <body' }
  exit 0
}

$userNameResult = Invoke-Git -Arguments @('config', '--get', 'user.name')
$userEmailResult = Invoke-Git -Arguments @('config', '--get', 'user.email')
Write-HookLog ("git config user.name exit={0} output=`"{1}`"" -f $userNameResult.ExitCode, $userNameResult.Output)
Write-HookLog ("git config user.email exit={0} output=`"{1}`"" -f $userEmailResult.ExitCode, $userEmailResult.Output)
if ($userNameResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($userNameResult.Output) -or $userEmailResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($userEmailResult.Output)) {
  Write-HookLog 'decision=blocked reason=missing_git_identity'
  Emit-Json @{ continue = $false; reason = 'BLOCKED: git user.name and user.email must be configured' }
  exit 0
}

$addResult = Invoke-Git -Arguments @('add', '--', 'index.html')
Write-HookLog ("git add exit={0} output=`"{1}`"" -f $addResult.ExitCode, $addResult.Output)
if ($addResult.ExitCode -ne 0) {
  Write-HookLog 'decision=continue reason=git_add_failed'
  Emit-Json @{ continue = $true }
  exit 0
}

$stagedDiffResult = Invoke-Git -Arguments @('diff', '--cached', '--quiet', '--', 'index.html')
Write-HookLog ("git diff --cached --quiet exit={0} output=`"{1}`"" -f $stagedDiffResult.ExitCode, $stagedDiffResult.Output)
if ($stagedDiffResult.ExitCode -eq 0) {
  Write-HookLog 'decision=continue reason=no_staged_diff_after_add'
  Emit-Json @{ continue = $true }
  exit 0
}

$commitResult = Invoke-Git -Arguments @('commit', '--only', '-m', 'auto: update index.html', '--', 'index.html')
Write-HookLog ("git commit exit={0} output=`"{1}`"" -f $commitResult.ExitCode, $commitResult.Output)
if ($commitResult.ExitCode -ne 0) {
  Write-HookLog 'decision=continue reason=git_commit_failed'
  Emit-Json @{ continue = $true }
  exit 0
}

$hashResult = Invoke-Git -Arguments @('rev-parse', 'HEAD')
Write-HookLog ("git rev-parse HEAD exit={0} output=`"{1}`"" -f $hashResult.ExitCode, $hashResult.Output)

Emit-Json @{ continue = $true }
