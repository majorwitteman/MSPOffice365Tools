## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'

try {

    $Public  = @( Get-ChildItem -Path $env:GITHUB_WORKSPACE\MSPOffice365Tools\public\ )
    $Private = @( Get-ChildItem -Path $env:GITHUB_WORKSPACE\MSPOffice365Tools\private\ )
    $fileList = $public.foreach({$_.FullName})
    $fileList += $private.foreach({$_.FullName})

    #region Read the module manifest
    $manifestFilePath = "$env:GITHUB_WORKSPACE\MSPOffice365Tools\MSPOffice365Tools.psd1"
    $manifestContent = Get-Content -Path $manifestFilePath -Raw
    #endregion

    $functions = $Public.BaseName

    #region Update the module version based on the build version and limit exported functions
    ## Use the AppVeyor build version as the module version
    $replacements = @{
        "ModuleVersion = '.*'" = "ModuleVersion = '1.0.$([int]$env:GITHUB_RUN_NUMBER+40)'"
    }

    $replacements.GetEnumerator() | Foreach-Object {
        $manifestContent = $manifestContent -replace $_.Key, $_.Value
    }

    $manifestContent | Set-Content -Path $manifestFilePath
    Set-Location -Path .\MSPOffice365Tools
    Update-ModuleManifest -Path $manifestFilePath -FunctionsToExport $functions -FileList $fileList
    Set-Location -Path ..\
    #endregion

} catch {
    Write-Error -Message $_.Exception.Message
    ## Ensure the build knows to fail
    $host.SetShouldExit($LastExitCode)
}