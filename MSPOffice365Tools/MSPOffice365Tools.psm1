#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

$365SkuTable = Import-LocalizedData -BaseDirectory $PSScriptRoot\private -FileName SkuTable.psd1

$ExchangeSessionNamePreference = "MSExchange"

#Export-ModuleMember -Function $Public.Basename -Variable ExchangeSessionNamePreference