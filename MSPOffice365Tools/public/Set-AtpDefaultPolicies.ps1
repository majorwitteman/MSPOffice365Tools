function Set-AtpDefaultPolicies {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $NoSafeAttachmentPolicy,
        
        [Parameter()]
        [switch]
        $NoSafeLinksPolicy,

        [Parameter()]
        [string]
        $SafeAttachmentRedirectEmailAddress
    )


    $domains = Get-AcceptedDomain | Where-Object { $_.DomainName -notmatch "\.mail\.onmicrosoft\.com"}
    $defaultDomainName = $domains.Where({$_.Default}).DomainName
    if($SafeAttachmentRedirectEmailAddress) {
        $safeAttachRedirectEmail = $SafeAttachmentRedirectEmailAddress
    }
    else {
        $safeAttachRedirectEmail = "atp_redirect@$defaultDomainName"
    }

    if (-not ($null = Get-Mailbox -Identity $safeAttachRedirectEmail -ErrorAction SilentlyContinue))
    {
        Write-Error -Message "Mailbox '$safeattachredirectemail' does not exist. Please create this mailbox or specify an existing mailbox before continuing."
        break
    }

    if(-not $NoSafeLinksPolicy) {
        $safeLinksPolicy = New-SafeLinksPolicy -Name "Default Safe Links Policy"
        $safeLinksRule = New-SafeLinksRule -Name "Default Safe Links Rule" -SafeLinksPolicy $safeLinksPolicy.Name -RecipientDomainIs $domains.DomainName
        $safeLinksPolicy | Set-SafeLinksPolicy -IsEnabled $true
        Set-AtpPolicyForO365 -EnableSafeLinksForClients $true
    }

    if(-not $NoSafeAttachmentPolicy) {
        $safeAttachPolicy = New-SafeAttachmentPolicy -Name "Default Safe Attachment Policy" -Redirect $true -RedirectAddress $safeAttachRedirectEmail -Action DynamicDelivery
        $safeAttachRule = New-SafeAttachmentRule -Name "Default Safe Attachment Rule" -SafeAttachmentPolicy $safeAttachPolicy.Name -ExceptIfSentTo $safeAttachRedirectEmail -RecipientDomainIs $domains.DomainName
        $safeAttachPolicy | Set-SafeAttachmentPolicy -Enable $true
        Set-AtpPolicyForO365 -EnableATPForSPOTeamsODB $true
    }
}