function Get-MsolUserMFA {
    [Cmdletbinding()]
    param (
        $TenantObject
    )

    foreach($tenant in $TenantObject) {
        $tenantUsers = Get-MsolUser -All -TenantId $tenant.tenantid
        foreach($user in $tenantUsers) {
            [pscustomobject]@{
                TenantName                  = $tenant.Name
                TenantDomain                = $tenant.DefaultDomainName
                UserPrincipalname           = $user.UserPrincipalName
                UserDisplayName             = $user.DisplayName
                UserBlockCredential         = $user.BlockCredential
                UserIsLicensed              = $user.isLicensed
                UserMFA                     = $user.StrongAuthenticationRequirements.State
                UserDefaultMFA              = $user.StrongAuthenticationMethods.Where({ $_.IsDefault }).MethodType
                UserOtherMFA                = $user.StrongAuthenticationMethods.Where({ -not ($_.IsDefault) }).MethodType -join '; '
                UserLastPasswordChange      = $user.LastPasswordChangeTimestamp
                UserPasswordNeverExpires    = $user.PasswordNeverExpires
                UserLastDirSync             = $user.LastDirSyncTime
                UserType                    = $user.UserType
            }
        }
    }
}