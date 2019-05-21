function Get-RWAllClientMailboxForwarding {
    [cmdletbinding()]
    param()
    $credential = Get-Credential -Message "Enter your Office 365 credentials (delegated admin)"
    Connect-MsolService -Credential $credential
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