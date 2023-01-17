## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'

try {

    ## Don't upload the build scripts and other artifacts when uploading to the PowerShell Gallery

    ## Remove all of the files/folders to exclude out of the main folder
    $excludeFromPublish = @(
        'MSPOffice365Tools\\build.ps1'
        'MSPOffice365Tools\\install.ps1'
        'MSPOffice365Tools\\publish.ps1'
        'MSPOffice365Tools\\appveyor\.yml'
        'MSPOffice365Tools\\\.git'
        'MSPOffice365Tools\\\.github'
        'MSPOffice365Tools\\\.nuspec'
        'MSPOffice365Tools\\README\.md'
        'MSPOffice365Tools\\TestResults\.xml'
    )

    $exclude = $excludeFromPublish -join '|'
    Get-ChildItem -Path $env:GITHUB_WORKSPACE -Recurse | Where-Object { $_.FullName -match $exclude } | Remove-Item -Force -Recurse

    ## Publish module to PowerShell Gallery
    $publishParams = @{
        Path        = "$env:GITHUB_WORKSPACE\MSPOffice365Tools"
        NuGetApiKey = $env:psgalleryKey
    }
    Publish-Module @publishParams
    # Publish-PMModule @publishParams

} catch {
    Write-Error -Message $_.Exception.Message
    $host.SetShouldExit($LastExitCode)
}