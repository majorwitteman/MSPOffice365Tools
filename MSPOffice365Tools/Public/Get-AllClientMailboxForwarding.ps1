function Get-AllClientMailboxForwarding {
    [cmdletbinding()]
    param()
    $contracts = Get-MsolPartnerContract
    $object = @()
    foreach ($contract in $contracts) {
    
        Connect-RwExchange -ExchangeOnline -Domain $contract.DefaultDomainName -Credential $credential
        Write-Verbose "Getting mailboxes and forwarding information for $($contract.name)"
        $forwards = @()
        $forwards = Get-RWMailboxFowarding | Select-Object -Property @{n = 'ClientName'; e = { $contract.Name } }, *
        Disconnect-RwExchange
        $object += $forwards
        $forwards
    
    }
    $object
}