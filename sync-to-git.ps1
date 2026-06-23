param(
  [string]$Message = "",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$repos = @(
  @{ Name = "admin-app";    Path = Join-Path $root "admin-app" },
  @{ Name = "backend-app";  Path = Join-Path $root "backend-app" },
  @{ Name = "rail-backend"; Path = Join-Path $root "rail-backend" },
  @{ Name = "web-app";      Path = Join-Path $root "web-app" }
)

function Write-Step($text) { Write-Host "=== $text ===" -ForegroundColor Cyan }
function Write-Ok($text)   { Write-Host "$text" -ForegroundColor Green }
function Write-Warn($text) { Write-Host "$text" -ForegroundColor Yellow }
function Write-Fail($text) { Write-Host "$text" -ForegroundColor Red }

$defaultMsg = "sync: update $((Get-Date -Format 'yyyy-MM-dd HH:mm'))"

# ── Build check ─────────────────────────────────────────────────────────────
if (-not $SkipBuild) {
  Write-Step "TypeScript check: backend-app"
  Push-Location (Join-Path $root "backend-app")
  try {
    npm run build 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Fail "backend-app build FAILED."; exit 1 }
    Write-Ok "backend-app build passed."
  } finally { Pop-Location }

  Write-Step "TypeScript check: web-app"
  Push-Location (Join-Path $root "web-app")
  try {
    npm run build 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Fail "web-app build FAILED."; exit 1 }
    Write-Ok "web-app build passed."
  } finally { Pop-Location }
}

# ── Commit & push each sub-repo ────────────────────────────────────────────
foreach ($repo in $repos) {
  $name = $repo.Name
  $path = $repo.Path
  if (-not (Test-Path (Join-Path $path ".git"))) {
    Write-Warn "$name — not a git repo, skipping"
    continue
  }

  Write-Step "$name — add & commit"
  Push-Location $path
  try {
    git add -A
    $dirty = git diff --cached --quiet; $hasChanges = $LASTEXITCODE -ne 0
    if ($hasChanges) {
      $msg = if ($Message) { "$Message ($name)" } else { $defaultMsg }
      git commit -m $msg
      git push
      Write-Ok "$name — committed & pushed"
    } else {
      Write-Warn "$name — nothing to commit"
    }
  } finally { Pop-Location }
}

# ── Root repo: commit submodule ref bumps ──────────────────────────────────
Write-Step "root — update submodule refs"
Push-Location $root
try {
  git add -A
  $dirty = git diff --cached --quiet; $hasChanges = $LASTEXITCODE -ne 0
  if ($hasChanges) {
    $msg = if ($Message) { $Message } else { $defaultMsg }
    git commit -m $msg
    git push
    Write-Ok "root — committed & pushed"
  } else {
    Write-Warn "root — nothing to commit"
  }
} finally { Pop-Location }

Write-Step "Done — all repos synced"
