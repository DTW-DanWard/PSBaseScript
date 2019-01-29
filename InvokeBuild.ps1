[CmdletBinding()]
param()

$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
  $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
  $DebugPreference = "Continue"
}

Set-StrictMode -Version Latest

$ProjectRoot = $env:BHProjectPath
if (-not $ProjectRoot) {
  $ProjectRoot = $PSScriptRoot
}

# module path is NOT set by default for script projects so set now
$env:BHModulePath = Join-Path -Path $env:BHProjectPath -ChildPath $env:BHProjectName

$Timestamp = "{0:yyyyMMdd-HHmmss}" -f (Get-Date)
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
$Line = '-' * 70

$Verbose = @{}
if ($env:BHBranchName -ne "master" -or $env:BHCommitMessage -match "!verbose") {
  $Verbose = @{Verbose = $True}
}

# Synopsis: By default run Test
task Default Test

# Synopsis: List tasks in this build file
task . { Invoke-Build ? }

# Synopsis: Initialze build helpers and displays settings
task Init {
  $Line
  Set-Location $ProjectRoot
  'Build System Details:'
  Get-Item env:BH* | Sort-Object Name
  "`n"
}

# Synopsis: Run unit tests in current PowerShell instance
task Test Init, {
  $Line
  "`nTesting with PowerShell $PSVersion"

  $Params = @{
    Path         = (Join-Path -Path $ProjectRoot -ChildPath Tests)
    PassThru     = $true
    OutputFormat = "NUnitXml"
    OutputFile   = (Join-Path -Path $ProjectRoot -ChildPath $TestFile)
  }

  # don't assume there are code files (edge case when first setting up); if code files add to params
  $CodeFiles = Get-ChildItem $env:BHModulePath -Recurse -Include "*.psm1", "*.ps1"
  if ($null -ne $CodeFiles) {
    $Params.CodeCoverage = $CodeFiles.FullName
  }

  # Integration tagged tests only run on the native developer machine; not on build server, not in test container
  if (-not (($env:BHBuildSystem -eq 'Unknown') -and ($env:COMPUTERNAME -eq 'PONDSURFACE2'))) {
    $Params.ExcludeTag = @('Integration')
  }

  # Gather test results. Store them in a variable and file
  $TestResults = Invoke-Pester @Params

  # In Appveyor?  Upload our tests! #Abstract this into a function?
  If ($env:BHBuildSystem -eq 'AppVeyor') {
    (New-Object 'System.Net.WebClient').UploadFile(
      "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
      (Join-Path -Path $ProjectRoot -ChildPath $TestFile))
  }

  Remove-Item (Join-Path -Path $ProjectRoot -ChildPath $TestFile) -Force -ErrorAction SilentlyContinue

  # code coverage badge changes and helper function adapted from:
  # http://wragg.io/add-a-code-coverage-badge-to-your-powershell-deployment-pipeline/

  # if failed tests then write an error to ensure does not continue to build & deploy steps
  # else if passed tests and on build server and on master branch then update code coverage badge
  # (does not have to be a deploy, just on build server and master)
  if ($TestResults.FailedCount -gt 0) {
    Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
  } elseif ($env:BHBuildSystem -ne 'Unknown' -and $env:BHBranchName -eq 'master') {
    # update code coverage badge on readme.md
    $CoveragePercent = [math]::floor(100 - (($TestResults.CodeCoverage.NumberOfCommandsMissed / $TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))
    "Code coverage badge: $CoveragePercent"
  }
  "`n"
}

# Synopsis: Run PSScriptAnalyzer on PowerShell code files
Task Analyze Init, {
  $Line
  "`nRunning PSScriptAnalyzer"

  # run script analyzer on all files EXCEPT build files in project root
  Get-ChildItem -Path $ProjectRoot -Recurse | Where-Object { @('.ps1', '.psm1') -contains $_.Extension -and $_.DirectoryName -ne $ProjectRoot } | ForEach-Object {
    # don't worry: Write-Host is *barely* used
    $Results = Invoke-ScriptAnalyzer -Path $_.FullName -ExcludeRule PSAvoidUsingWriteHost,PSAvoidUsingConvertToSecureStringWithPlainText
    if ($null -ne $Results) {
      Write-Build Red "PSScriptAnalyzer found issues in: $($_.Name)"
      $Results | ForEach-Object {
        Write-Build Red "$($_.Line) : $($_.Message)"
      }
      Write-Build Cyan "See full results with: Invoke-ScriptAnalyzer -Path $($_.FullName)"
      Write-Error 'Fix above issues'
    }
  }
  Write-Build Cyan "Analyze successful"
}
