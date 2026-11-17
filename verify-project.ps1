$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$src = Join-Path $root "src"
$validationFailures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Check([bool]$condition, [string]$message) {
    $script:checks++
    if ($condition) { Write-Host "PASS  $message" -ForegroundColor Green }
    else { $script:validationFailures.Add($message); Write-Host "FAIL  $message" -ForegroundColor Red }
}

# Parse every XAML document and ensure every x:Class has a matching code-behind file and handlers.
$xamlFiles = Get-ChildItem -Path (Join-Path $src "RivalsMacro.App") -Recurse -Filter *.xaml
$xNs = "http://schemas.microsoft.com/winfx/2006/xaml"
$knownEvents = @("Click", "SelectionChanged", "Checked", "Unchecked", "Loaded", "Unloaded", "Toggled", "ValueChanged")
foreach ($file in $xamlFiles) {
    try { [xml]$doc = Get-Content -LiteralPath $file.FullName -Raw }
    catch { Check $false "XAML XML parse: $($file.Name)"; continue }
    Check $true "XAML XML parse: $($file.Name)"
    $rootNode = $doc.DocumentElement
    $className = $rootNode.GetAttribute("Class", $xNs)
    if ([string]::IsNullOrWhiteSpace($className)) { continue }
    $codeBehind = [System.IO.Path]::ChangeExtension($file.FullName, ".xaml.cs")
    if (-not (Test-Path -LiteralPath $codeBehind)) {
        Check $false "Code-behind exists for $className"
        continue
    }
    $code = Get-Content -LiteralPath $codeBehind -Raw
    $shortName = ($className -split '\.')[-1]
    Check ($code -match "partial\s+class\s+$([regex]::Escape($shortName))\b") "Partial class exists for $className"
    Check ($code -match '\bInitializeComponent\s*\(') "InitializeComponent exists for $className"
    foreach ($node in $doc.SelectNodes("//*")) {
        foreach ($attr in $node.Attributes) {
            if ($knownEvents -contains $attr.LocalName -and -not [string]::IsNullOrWhiteSpace($attr.Value)) {
                $handler = [regex]::Escape($attr.Value)
                Check ($code -match "\b$handler\s*\(") "Event handler $($attr.Value) exists in $($file.Name)"
            }
        }
    }
}

# Explicit regression guard for the error reported in generated XamlTypeInfo.g.cs.
$logPath = Join-Path $src "RivalsMacro.App/Models/LogEntry.cs"
$logCode = Get-Content -LiteralPath $logPath -Raw
Check ($logCode -match 'public\s+sealed\s+class\s+LogEntry\b') "LogEntry is a mutable class, not a positional record"
Check ($logCode -match 'public\s+LogEntry\s*\(\s*\)') "LogEntry has a public parameterless constructor"
foreach ($property in @("Time", "Level", "Message")) {
    $pattern = "public\s+string\s+$property\s*\{\s*get\s*;\s*set\s*;\s*\}"
    Check ($logCode -match $pattern) "LogEntry.$property has a public set accessor"
}
Check ($logCode -notmatch '\binit\s*;') "LogEntry has no init-only properties"
$testCode = Get-Content -LiteralPath (Join-Path $src "RivalsMacro.Core.Tests/Program.cs") -Raw
Check ($testCode -match 'LogEntryPropertiesAreWritable') "Compile-time LogEntry setter regression test is present"
$testProject = Get-Content -LiteralPath (Join-Path $src "RivalsMacro.Core.Tests/RivalsMacro.Core.Tests.csproj") -Raw
Check ($testProject -match 'LogEntry\.cs') "Tests compile the same LogEntry source file as the app"

# Guard previous XAML/API regressions and version drift.
$appProject = Get-Content -LiteralPath (Join-Path $src "RivalsMacro.App/RivalsMacro.App.csproj") -Raw
$coreProject = Get-Content -LiteralPath (Join-Path $src "RivalsMacro.Core/RivalsMacro.Core.csproj") -Raw
Check ($appProject -match '<Version>0\.3\.0\.4</Version>') "App project version is 0.3.0.4"
Check ($coreProject -match '<Version>0\.3\.0\.4</Version>') "Core project version is 0.3.0.4"
$allXaml = ($xamlFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
Check ($allXaml -notmatch 'PaneBackground\s*=') "No unsupported NavigationView.PaneBackground property"
Check ($allXaml -notmatch 'Severity\s*=\s*"Info"') "InfoBar severity uses valid enum names"
$invalidSeverity = @([regex]::Matches($allXaml, 'Severity\s*=\s*"([^"]+)"') | Where-Object { $_.Groups[1].Value -notin @("Informational", "Success", "Warning", "Error") })
Check ($invalidSeverity.Length -eq 0) "All InfoBar severity values are supported"

# Check project references resolve to files.
foreach ($projectFile in Get-ChildItem -Path $src -Recurse -Filter *.csproj) {
    [xml]$projectXml = Get-Content -LiteralPath $projectFile.FullName -Raw
    foreach ($reference in $projectXml.SelectNodes("//*[local-name()='ProjectReference']")) {
        $include = $reference.GetAttribute("Include")
        if ([string]::IsNullOrWhiteSpace($include)) { continue }
        $resolved = [System.IO.Path]::GetFullPath((Join-Path $projectFile.DirectoryName $include))
        Check (Test-Path -LiteralPath $resolved) "Project reference resolves: $include"
    }
}

Write-Host "`nSource validation: $($checks - $validationFailures.Count)/$checks passed."
if ($validationFailures.Count -gt 0) {
    Write-Host "Failures:" -ForegroundColor Red
    $validationFailures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    throw "Source validation failed with $($validationFailures.Count) error(s)."
}
Write-Host "Source validation completed successfully." -ForegroundColor Green
