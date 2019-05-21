function Add-RWExchOnlineMailboxPermission {
    <#
.SYNOPSIS
Must specify FullAccess, SendAs, or both.
#>
    param (
        [string]$Mailbox,
        [string]$User,
        [switch]$FullAccess,
        [switch]$SendAs
    )

    if ($FullAccess.IsPresent) {
        Add-MailboxPermission -Identity $mailbox -User $user -AccessRights FullAccess
    }

    if ($SendAs.IsPresent) {
        Add-RecipientPermission -Identity $mailbox -Trustee $user -AccessRights SendAs
    }

}