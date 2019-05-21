function Set-MsolUserPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserPrincipalName,
        [boolean]$RevokeToken = $true,
        [boolean]$ForceChangePassword = $true
    )
    
    begin {
        #should check for connectivity to MSOL and AzureAD
    }
    
    process {
        foreach ($user in $UserPrincipalName) {
            try {
                Get-MsolUser -UserPrincipalName $user -ErrorAction Stop -OutVariable msolUser | Out-Null
            }
            catch {
                Write-Error -Message "User not found. User: $user"
                Continue
            }
            Write-Verbose -Message "Setting password for $user"
            $newPassword = Set-MsolUserPassword -UserPrincipalName $user -ForceChangePassword $ForceChangePassword
            $obj = [PSCustomObject]@{
                UserPrincipalName                   = $user
                DisplayName                         = $msolUser.DisplayName
                NewPassword                         = $newPassword
                PreviousLastPasswordChangeTimeStamp = $msolUser.LastPasswordChangeTimestamp
            }
            $obj

            if ($RevokeToken) {
                Write-Verbose -Message "Initiating user log out. User: $user"
                Revoke-AzureADUserAllRefreshToken -ObjectId $msolUser.ObjectId
            }
        }
    }
    
    end {
    }
}