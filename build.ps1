param(
  [ValidateSet('Analyze','Test')]
  [string]$Task = 'Default'
)

'InvokeBuild', 'BuildHelpers', 'Pester', 'PSScriptAnalyzer' | ForEach-Object {
  $ProgressPreference = 'SilentlyContinue'
  if ($null -eq (Get-Module -Name $_ -ListAvailable)) { Install-Module -Name $_ -Force -AllowClobber }
  Import-Module -Name $_ -Force
}

# delete build help environment variables if they already exist
Get-Item env:BH* | Remove-Item
# now re/set build environment variables
Set-BuildEnvironment

Invoke-Build -File .\InvokeBuild.ps1 -Task $Task -Result Result
if ($Result.Error) {
  exit 1
} else {
  exit 0
}
