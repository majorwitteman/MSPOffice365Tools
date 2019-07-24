## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'


gci -recurse
<#
try {

    ## Don't upload the build scripts and other artifacts when uploading to the PowerShell Gallery
    $tempmoduleFolderPath = "$env:Temp\MSPOffice365Tools"
    $null = mkdir $tempmoduleFolderPath

    ## Remove all of the files/folders to exclude out of the main folder
    $excludeFromPublish = @(
        'MSPOffice365Tools\\build.ps1'
        'MSPOffice365Tools\\install.ps1'
        'MSPOffice365Tools\\publish.ps1'
        'MSPOffice365Tools\\appveyor\.yml'
        'MSPOffice365Tools\\\.git'
        'MSPOffice365Tools\\\.nuspec'
        'MSPOffice365Tools\\README\.md'
        'MSPOffice365Tools\\TestResults\.xml'
        'MSPOffice365Tools\\private'
        'MSPOffice365Tools\\public'
    )
    $exclude = $excludeFromPublish -join '|'
    Get-ChildItem -Path $env:APPVEYOR_BUILD_FOLDER -Recurse | Where-Object { $_.FullName -match $exclude } | Remove-Item -Force -Recurse

    ## Publish module to PowerShell Gallery
    $publishParams = @{
        Path        = $env:APPVEYOR_BUILD_FOLDER
        NuGetApiKey = $env:nuget_apikey
    }
    Publish-PMModule @publishParams

} catch {
    Write-Error -Message $_.Exception.Message
    $host.SetShouldExit($LastExitCode)
}
#>