function Get-RWMailboxSize {
    <#
.SYNOPSIS
Gets all mailboxes and the mailbox sizes. Fixes the built in TotalItemSize property by adding a TotalSizeInBytes field.
#>
    param(
        
    )

    $Mailbox = Get-Mailbox
    $Statistics = $Mailbox | Get-MailboxStatistics
    $Statistics | Add-Member -MemberType ScriptProperty -Name 'TotalSizeInBytes' -Value { $this.TotalItemSize -replace "(.*\()|,| [a-z]*\)", "" }
    Write-Output -InputObject $Statistics

}