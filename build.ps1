$private = Get-ChildItem -Path $PSScriptRoot\MSPOffice365Tools\public

$functionsToExport = $private.BaseName

$current = Import-LocalizedData -BaseDirectory .\MSPOffice365Tools -FileName MSPOffice365Tools.psd1

New-ModuleManifest -Path .\MSPOffice365Tools\MSPOffice365Tools.psd1 -FunctionsToExport $functionsToExport -Author "Rob Witteman" -RootModule '.\MSPOffice365Tools.psm1' -Guid $current.Guid