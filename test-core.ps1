$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "verify-project.ps1")
$project = Join-Path $PSScriptRoot "src/RivalsMacro.Core.Tests/RivalsMacro.Core.Tests.csproj"
dotnet run --project $project -c Release
if ($LASTEXITCODE -ne 0) { throw "Core tests failed with exit code $LASTEXITCODE." }
