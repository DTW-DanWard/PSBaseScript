Set-StrictMode -Version Latest

# test in this file are specific to a particular file, instead they test across all source files
# for example: making sure that help is properly defined for all functions

# get all source file paths
[string[]]$SourceScripts = $null
Get-ChildItem -Path $env:BHModulePath -Filter *.ps1 -Recurse | ForEach-Object {
  $SourceScripts += $_.FullName
}


#region Confirming all Source functions in the module have help defined
$SourceScripts | Where-Object { ($null -ne (Get-Content $_)) -and ((Get-Content $_).Trim() -ne '') } | ForEach-Object {
  $SourceScript = $_
  Describe "Source script: $SourceScript" { }
  $Functions = ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $SourceScript -Raw), [ref]$null, [ref]$null)).FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
  Describe 'Confirm all functions have help defined: Synopsis, Description, Parameters & Example' {

    It 'confirms help section exists for each function' {
      $Functions | Where-Object { $null -eq $_.GetHelpContent() } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Synopsis field has content for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and (($null -eq $_.GetHelpContent().Synopsis) -or ($_.GetHelpContent().Synopsis -eq '')) } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Description field has content for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and (($null -eq $_.GetHelpContent().Description) -or ($_.GetHelpContent().Description -eq '')) } | Select-Object Name | Should BeNullOrEmpty
    }

    # note: if a function does not have a parameter section defined at all, we can't call .Body.ParamBlock.Parameters.Count
    # have to check ParamBlock even exists

    # check if parameters are defined in help while no param is defined in code
    It 'confirms if any Parameters defined in help but no params actually defined in function for each function' {
      $Functions | ForEach-Object {
        if (($_.GetHelpContent().Parameters.Keys.Count -gt 0) -and
          ($null -eq (Get-Member -Name Parameters -InputObject $_.Body.ParamBlock) -or
            ($_.Body.ParamBlock.Parameters.Count -eq 0)
          )) { $_.Name }
      } | Should BeNullOrEmpty
    }

    # check if parameters are defined in code but none in help
    It 'confirms if any Parameters defined in code but none in help for each function' {
      $Functions | ForEach-Object {
        if (($_.GetHelpContent().Parameters.Keys.Count -eq 0) -and
          ($null -ne $_.Body.ParamBlock) -and
          ($null -ne $_.Body.ParamBlock.Parameters) -and
          ($_.Body.ParamBlock.Parameters.Count -gt 0)
        ) { $_.Name }
      } | Should BeNullOrEmpty
    }

    # check if parameter count matches in both help and code
    It 'confirms parameter count matches in both help and code for each function' {
      $Functions | ForEach-Object {
        $CodeParamCount = 0
        if (($null -ne $_.Body.ParamBlock) -and ($null -ne $_.Body.ParamBlock.Parameters)) {
          $CodeParamCount = $_.Body.ParamBlock.Parameters.Count
        }
        if (($_.GetHelpContent().Parameters.Keys.Count) -ne $CodeParamCount) { $_.Name }
      } | Should BeNullOrEmpty
    }

    It 'confirms Parameter name(s) in help matches defined parameter name(s) on function for each function' {
      $Functions | Where-Object { $_.GetHelpContent().Parameters.Keys.Count -gt 0 } | ForEach-Object {
        $Function = $_
        # only do if parameters actually defined on function (else .Name will fail with null error)
        if (($null -ne (Get-Member -Name Parameters -InputObject $Function.Body.ParamBlock)) -and ($Function.Body.ParamBlock.Parameters.Count -gt 0)) {
          # use string expansion to get values as strings;
          $HelpParameters = "$($Function.GetHelpContent().Parameters.Keys | Sort-Object)"
          $DefinedParameters = "$($Function.Body.ParamBlock.Parameters.Name.VariablePath.UserPath | Sort-Object)"
          if ($HelpParameters -ne $DefinedParameters) { $_.Name }
        }
      } | Should BeNullOrEmpty
    }

    It 'confirms Parameter(s) have text content for each function' {
      $Functions | Where-Object { $_.GetHelpContent().Parameters.Keys.Count -gt 0 } | ForEach-Object {
        $Function = $_
        $Function.GetHelpContent().Parameters.Keys | ForEach-Object {
          $Key = $_
          if ($null -eq ($Function.GetHelpContent().Parameters.$Key) -or
            ($Function.GetHelpContent().Parameters.$Key) -eq '') {
            $Function.Name + ':' + $Key
          }
        }
      } | Should BeNullOrEmpty
    }

    It 'confirms at least one Example field for each function' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and ($_.GetHelpContent().Examples.Count -eq 0) } | Select-Object Name | Should BeNullOrEmpty
    }

    It 'confirms Example field(s) have content' {
      $Functions | Where-Object { ($null -ne $_.GetHelpContent()) -and ($_.GetHelpContent().Examples.Count -gt 0) } | ForEach-Object {
        $Function = $_
        # this probably should check across entire array but fallback notation not working in script, weird
        # just assume a single example and check that
        if ($Function.GetHelpContent().Examples.Trim() -eq '') { $_.Name }
      } | Should BeNullOrEmpty
    }
  }
}
#endregion
