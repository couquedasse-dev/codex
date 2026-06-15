$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envPath = Join-Path $repoRoot '.env'

if (-not (Test-Path -LiteralPath $envPath)) {
  Write-Error 'FIRECRAWL_API_KEY not found.'
  exit 1
}

$apiKey = $null
foreach ($line in [System.IO.File]::ReadAllLines($envPath)) {
  if ($line -match '^\s*FIRECRAWL_API_KEY\s*=\s*(.+?)\s*$') {
    $apiKey = $Matches[1].Trim().Trim('"')
    break
  }
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
  Write-Error 'FIRECRAWL_API_KEY not found.'
  exit 1
}

$env:FIRECRAWL_API_KEY = $apiKey
npx -y firecrawl-mcp
