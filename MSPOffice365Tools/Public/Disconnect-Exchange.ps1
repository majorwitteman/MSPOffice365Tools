function Disconnect-Exchange
{
<#
.SYNOPSIS
Disconnects the previously opened remote Exchange session, if Connect-Exchange was used. Must use an account from that tenant; cannot be a delegated admin.
#>
    Remove-PSSession -Name $ExchangeSessionNamePreference

}