## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'

try {

    $Public  = @( Get-ChildItem -Path $env:APPVEYOR_BUILD_FOLDER\MSPOffice365Tools\public\ )
    $Private = @( Get-ChildItem -Path $env:APPVEYOR_BUILD_FOLDER\MSPOffice365Tools\private\ )
    $publicFileList = $public.ForEach({
        Write-Output ".\public\$($_.Name)"
    })
    $privateFileList = $private.ForEach({
        Write-Output ".\private\$($_.Name)"
    })
    $ModuleFile = '.\MSPOffice365Tools\MSPOffice365Tools.psm1'

    #region Read the module manifest
    $manifestFilePath = "$env:APPVEYOR_BUILD_FOLDER\MSPOffice365Tools\MSPOffice365Tools.psd1"
    $manifestContent = Get-Content -Path $manifestFilePath -Raw
    #endregion

    $functions = $Public.BaseName

    #region Update the module version based on the build version and limit exported functions
    ## Use the AppVeyor build version as the module version
    $replacements = @{
        "ModuleVersion = '.*'" = "ModuleVersion = '$env:APPVEYOR_BUILD_VERSION'"
    }

    $replacements.GetEnumerator() | Foreach-Object {
        $manifestContent = $manifestContent -replace $_.Key, $_.Value
    }

    $manifestContent | Set-Content -Path $manifestFilePath
    Set-Location -Path .\MSPOffice365Tools
    Update-ModuleManifest -Path $manifestFilePath -FunctionsToExport $functions -FileList $public.FullName
    Get-Content -Path $manifestFilePath -Raw
    Set-Location -Path ..\
    #endregion

#     $content = foreach($import in @($Public + $Private))
#     {
#         Get-Content -Path $import.FullName
#     }

#     $additonal = @'
# $365SkuTable = Import-LocalizedData -BaseDirectory $env:APPVEYOR_BUILD_FOLDER -FileName SkuTable.psd1
# $ExchangeSessionNamePreference = "MSExchange"
# '@
#     $content += $additonal
#     Set-Content -Path $ModuleFile -Value $content
#     Move-Item -Path $ModuleFile -Destination $env:APPVEYOR_BUILD_FOLDER\MSPOffice365Tools.psm1
#     Move-Item -Path $manifestFilePath -Destination $env:APPVEYOR_BUILD_FOLDER\MSPOffice365Tools.psd1
#     Get-ChildItem -Path .\MSPOffice365Tools\private | Move-Item -Destination $env:APPVEYOR_BUILD_FOLDER\
#     Remove-Item $env:APPVEYOR_BUILD_FOLDER\.git -Recurse -Force


} catch {
    Write-Error -Message $_.Exception.Message
    ## Ensure the build knows to fail
    $host.SetShouldExit($LastExitCode)
}