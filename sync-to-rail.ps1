param(
  [switch]$Push,
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root "backend-app"
$dst = Join-Path $root "rail-backend"

Write-Host "=== Syncing backend-app -> rail-backend ===" -ForegroundColor Cyan

robocopy "$src\src" "$dst\src" /E /IS /IT /NP /NJH /NJS
robocopy "$src\prisma" "$dst\prisma" /E /IS /IT /NP /NJH /NJS

Copy-Item "$src\package.json" "$dst\package.json" -Force
Copy-Item "$src\railway.json" "$dst\railway.json" -Force
Copy-Item "$src\package-lock.json" "$dst\package-lock.json" -Force
Copy-Item "$src\tsconfig.json" "$dst\tsconfig.json" -Force
Copy-Item "$src\prisma.config.ts" "$dst\prisma.config.ts" -Force

Write-Host "Files synced." -ForegroundColor Green

if (-not $SkipBuild) {
  Write-Host "=== Installing deps + TypeScript check in rail-backend ===" -ForegroundColor Cyan
  Push-Location $dst
  npm install --silent 2>$null
  $ok = $true
  npx tsc --noEmit 2>$null | ForEach-Object { $ok = $false; Write-Host $_ -ForegroundColor Red }
  Pop-Location
  if (-not $ok) { Write-Host "TypeScript check FAILED. Aborting push." -ForegroundColor Red; exit 1 }
  Write-Host "TypeScript check passed." -ForegroundColor Green
}

if ($Push) {
  Write-Host "=== Committing and pushing rail-backend ===" -ForegroundColor Cyan
  Push-Location $dst
  git add -A
  git diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git commit -m "sync: mirror backend-app latest"
    git push
    Write-Host "rail-backend pushed." -ForegroundColor Green
  } else {
    Write-Host "Nothing to commit." -ForegroundColor Yellow
  }
  Pop-Location

  Push-Location $root
  git add -A
  git diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git commit -m "chore: update submodule refs after rail-backend sync"
    git push
    Write-Host "Root repo pushed." -ForegroundColor Green
  }
  Pop-Location
}

Write-Host "=== Done ===" -ForegroundColor Cyan
