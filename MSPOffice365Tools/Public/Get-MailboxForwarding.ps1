function Get-MailboxFowarding {
    <#
.SYNOPSIS
Gets all mailboxes and their forwarding information.
#>
    Get-Mailbox | Select-Object -Property DisplayName, DeliverToMailboxAndForward, ForwardingAddress, ForwardingSMTPAddress

}