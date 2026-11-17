$ErrorActionPreference = "Stop"
$project = Join-Path $PSScriptRoot "src/RivalsMacro.App/RivalsMacro.App.csproj"
dotnet run --project $project -c Debug -p:Platform=x64
