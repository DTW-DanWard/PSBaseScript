Set-StrictMode -Version Latest

#region Dot-source Source file associated with this test file
# if no value returned just exit; specific error is already written in Get-SourceScriptFilePath call
. (Join-Path -Path $PSScriptRoot -ChildPath Get-SourceScriptFilePath.ps1)
$SourceScript = Get-SourceScriptFilePath
if ($null -eq $SourceScript) { exit }
Describe "Re/loading: $SourceScript" { }
. $SourceScript
#endregion


#region Test default settings properties
Describe 'settings properties' {

  It 'flattens simple hashtable - parameter' {
    Convert-XYZFlattenHashtable -HT @{A=1; B=2} | Should Be '@{ A = 1 ; B = 2 }'
  }

  It 'flattens simple hashtable - pipeline' {
    @{A=1; B=2} | Convert-XYZFlattenHashtable | Should Be '@{ A = 1 ; B = 2 }'
  }

  It 'flattens nested hashtable' {
    # C and D should be sorted alphabetically
    Convert-XYZFlattenHashtable -HT @{A=1;B=@{D=4;C=3}} | Should Be '@{ A = 1 ; B = @{ C = 3 ; D = 4 } }'
  }

  It 'flattens ordered dictionary, keeping initial key order' {
    # C and D should be sorted alphabetically
    Convert-XYZFlattenHashtable -HT ([ordered]@{C=1;B=2;D=3;A=4}) | Should Be '@{ C = 1 ; B = 2 ; D = 3 ; A = 4 }'
  }
}
#endregion
