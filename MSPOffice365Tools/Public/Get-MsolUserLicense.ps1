function Get-MsolUserLicense {
    <#
.Synopsis
   Takes Microsoft.Online.Administration.User object and provides separated license info
.DESCRIPTION
   Long description
.EXAMPLE
   Get-MsolUser | Get-RWMsolUserLicense
.EXAMPLE
   $users = Get-MsolUser | Where-Object {$_.IsLicensed -eq $True}
   $users | Get-RWMsolUserLicense
   $users | Export-CSV C:\Temp\Users.csv
#>
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $LicensedUsers
    )

    Begin {
        $collection = @()
        $skuPartNumbers = (Get-MsolAccountSku).SkuPartNumber
    }
    Process {
        foreach ($l in $licensedUsers) {
            $userSkus = $l.Licenses.AccountSku.SkuPartNumber
            $obj = [pscustomobject]@{
                DisplayName       = $l.DisplayName
                UserPrincipalName = $l.UserPrincipalName
                SignInBlocked     = $l.BlockCredential
            }
            foreach ($skuPN in $skuPartNumbers) {
                $present = ""
                if ($skuPN -in $userSkus) {
                    $present = "X"
                }
                Write-Debug $skuPN
                Write-Verbose -Message "Adding license $365SkuTable[$skuPn] for user $($l.DisplayName)"
                $obj | Add-Member -Name $365SkuTable[$skuPN] -MemberType NoteProperty -Value $present
            }
            $obj
        }
    }
    End {
        $collection
    }
}