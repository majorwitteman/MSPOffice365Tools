function Get-AllClientMailboxForwarding {
    [cmdletbinding()]
    param()

    begin {
        $contracts = Get-MsolPartnerContract
    }

    process {
        foreach ($contract in $contracts) {
            Write-Verbose "Getting mailboxes and forwarding information for $($contract.name)"
            $forwards = Get-MailboxFowarding | Select-Object -Property @{n = 'ClientName'; e = { $contract.Name } }, *
            $forwards
        }
    }
}