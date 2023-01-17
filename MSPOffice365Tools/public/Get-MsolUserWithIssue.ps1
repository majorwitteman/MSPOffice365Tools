<#
.SYNOPSIS
    Uses MSOnline and Exchange to get disabled users and shared mailboxes with licenses assigned.
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Get-MsolUserWithIssue {
    [CmdletBinding()]
    param (
        # PSCredential for Exchange Online, must use app password due to MFA
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )
    
    begin {
        try {
            $tenants = Get-MsolPartnerContract -ErrorAction Stop
        }
        catch {
            Write-Error "You must connect to Office 365 first with Connect-MsolService"
        }
    }
    
    process {
        foreach ($contract in $tenants) {
            $disabledUsersWithLicense = Get-MsolUser -TenantId $contract.TenantId -EnabledFilter DisabledOnly -All | Where-Object isLicensed
            $sessionParams = @{
                ConnectionUri = "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($contract.DefaultDomainName)"
                ConfigurationName = "Microsoft.Exchange"
                Authentication = "Basic"
                AllowRedirection = $true
                Credential = $credential
            }
            $session = New-PSSession @sessionParams
            $null = Import-PSSession -Session $session -CommandName "Get-Mailbox" -AllowClobber
            $sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox
            $licensedSharedMailboxes = foreach ($mailbox in $sharedMailboxes) {
                Write-Debug -Message "Looking for $($mailbox.UserPrincipalName)"
                Get-MsolUser -UserPrincipalName $mailbox.UserPrincipalName -TenantId $contract.TenantId | Where-Object isLicensed
            }

            Remove-PSSession -Session $session
            
            foreach ($u in $disabledUsersWithLicense) {
                [PSCustomObject]@{
                    UserPrincipalName = $u.UserPrincipalName
                    Licenses = $u.Licenses.AccountSkuId -join '; '
                    Disabled = $u.BlockCredential
                    Issue = "DisabledAccountWithLicense"
                }
            }

            foreach ($u in $licensedSharedMailboxes) {
                [PSCustomObject]@{
                    UserPrincipalName = $u.UserPrincipalName
                    MailboxType = $u.RecipientTypeDetails
                    Licenses = $u.Licenses.AccountSkuId -join '; '
                    Disabled = $u.BlockCredential
                    Issue = "SharedMailboxWithLicense"
                }
            }
        }
    }
    
    end {
        
    }
}