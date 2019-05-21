$private = Get-ChildItem -Path $PSScriptRoot\MSPOffice365Tools\public

$functionsToExport = $private.BaseName

$current = Import-LocalizedData -BaseDirectory .\MSPOffice365Tools -FileName MSPOffice365Tools.psd1

$description = "Collection of Office 365 PowerShell tools. Primarily aimed at MSP usage."

$params = @{
    Path                    = '.\MSPOffice365Tools\MSPOffice365Tools.psd1'
    FunctionsToExport       = $functionsToExport
    Author                  = "Rob Witteman"
    Description             = $description
    RootModule              = ".\MSPOffice365Tools.psm1"
    Guid                    = $current.Guid
    DefaultCommandPrefix    = "RW"
}

Update-ModuleManifest @params