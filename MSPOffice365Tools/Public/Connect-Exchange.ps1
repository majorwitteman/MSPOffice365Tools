$ExchangeSessionNamePreference = "MSExchange"

function Connect-Exchange
{
<#
.SYNOPSIS
Connect to a remote Exchange server. Specify -ExchangeOnline to connect Office 365 or specify -ConnectionURI with the https://mail.domain.com/powershell link to the server you want to connect to. You can provide a credential with -Credential or let the function prompt for a credential. You can also specify an alternate session name.

For Exchange Online, you can use delegated adminstration and provide a -Domain to connect to any tenant using your own credentials.
#>
    param (
        [Parameter(ParameterSetName="Online")][Alias("Online")][switch]$ExchangeOnline,
        [Parameter(ParameterSetName="OnPrem")][string]$ConnectionURI,
        [Parameter(ParameterSetName="Online")][string]$Domain,
        [ValidateSet("Default","Basic","Kerberos")]$Authentication = "Basic",
        [string]$SessionName = $ExchangeSessionNamePreference,
        [PSCredential]$Credential
        )

    $ExchangeSessionNamePreference = $SessionName

    if($ExchangeOnline.IsPresent){
        if($Domain){
            $ConnectionURI = "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$Domain"
        }
        else{
            $ConnectionURI = "https://outlook.office365.com/powershell"
        }
    }

    if($Credential -eq $null) {
        $Credential = Get-Credential -Message "Specify credentials for $ConnectionURI"
    }

    $ExchangeSession = New-PSSession -Name $SessionName -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionURI -AllowRedirection -Authentication $Authentication -Credential $Credential
    Import-Module -ModuleInfo (Import-PSSession -Session $ExchangeSession -DisableNameChecking -AllowClobber)

}