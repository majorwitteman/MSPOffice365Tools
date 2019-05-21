function Add-OneDriveAdmin {
    [CmdletBinding()]
    param (
        [string]$UserPrincipalName,
        [string]$UPNToAdd
    )

    process {
        $siteUrl = Get-SPOSite -Filter "Owner -eq $UserPrincipalName" -IncludePersonalSite $true | Select-Object -ExpandProperty Url
        Set-SPOUser -Site $siteUrl -LoginName $UPNToAdd -IsSiteCollectionAdmin $true
    }
}