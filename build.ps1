$ErrorActionPreference = "Stop"
$solution = Join-Path $PSScriptRoot "src/RivalsMacro.sln"
$testProject = Join-Path $PSScriptRoot "src/RivalsMacro.Core.Tests/RivalsMacro.Core.Tests.csproj"

Write-Host "[1/4] Validating XAML and source contracts..." -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "verify-project.ps1")

Write-Host "[2/4] Restoring solution packages..." -ForegroundColor Cyan
dotnet restore $solution
if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed with exit code $LASTEXITCODE." }

Write-Host "[3/4] Running core and XAML-model regression tests..." -ForegroundColor Cyan
dotnet run --project $testProject -c Release --no-restore
if ($LASTEXITCODE -ne 0) { throw "Regression tests failed with exit code $LASTEXITCODE. Build cancelled." }

Write-Host "[4/4] Building full solution (Debug x64)..." -ForegroundColor Cyan
dotnet build $solution -c Debug -p:Platform=x64 --no-restore
if ($LASTEXITCODE -ne 0) { throw "Solution build failed with exit code $LASTEXITCODE." }
Write-Host "Build and regression checks completed successfully." -ForegroundColor Green
