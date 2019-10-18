function Convert-GroupADSyncToCloud {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [psobject[]]
        $GroupObject,

        [Parameter(Mandatory = $true)]
        [string]$ManagedByDefaultUserEmailAddress,

        [Parameter(Mandatory = $true)]
        [string]$ModeratedByDefaultUserEmailAddress,
        
        [switch]$WhatIf
    )

    begin {
        if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.ComputerName -eq 'outlook.office365.com' } )) {
            Write-Warning "Please connect to Exchange Online to convert distribution groups from AD synchronized to cloud-only; exiting script"
            Exit
        }
    }

    process {
        foreach ($dgObject in $GroupObject) {

            $ManagedBy = if ($dgObject.Group.ManagedBy -match "Organization Management" -or -not $dgObject.Group.ManagedBy) {
                $ManagedByDefaultUserEmailAddress
            }
            else {
                $dgObject.Group.ManagedBy | Get-Recipient | Select-Object -ExpandProperty PrimarySMTPAddress
            }

            $ModerateBy = if ($dgObject.Group.ManagedBy -match "Organization Management") {
                $ModeratedByDefaultUserEmailAddress
            }
            else {
                $dgObject.Group.ModeratedBy | Get-Recipient | Select-Object -ExpandProperty PrimarySMTPAddress
            }

            # $Members = $dgObject.Members | Select-Object -ExpandProperty PrimarySMTPAddress

            $newDGParam = @{
                Name                               = $dgObject.Group.Name
                ModeratedBy                        = $ModerateBy
                RequireSenderAuthenticationEnabled = $dgObject.Group.RequireSenderAuthenticationEnabled
                ModerationEnabled                  = $dgObject.Group.ModerationEnabled
                DisplayName                        = $dgObject.Group.DisplayName
                Alias                              = $dgObject.Group.Alias
                ManagedBy                          = $ManagedBy
                PrimarySmtpAddress                 = $dgObject.Group.PrimarySMTPAddress
                Members                            = ($dgObject.Members.PrimarySMTPAddress | Where-Object { $_.Length -gt 0 })
                SendModerationNotifications        = $dgObject.Group.SendModerationNotifications
                WhatIf                             = $WhatIf
            }
            Write-Verbose -Message "Re-creating distribution group: $($dgObject.Group.Name)"
            $newDG = New-DistributionGroup @newDGParam

            Write-Verbose -Message "Re-adding Email Addresses to distribution group: $($dgObject.Group.Name)"
            $setDGParam = @{
                Identity       = $newDG.Identity
                EmailAddresses = $dgObject.Group.EmailAddresses
                WhatIf         = $WhatIf
            }
            Set-DistributionGroup @setDGParam
        }
    }
    
}