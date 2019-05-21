function Connect-Exchange {
    <#
.SYNOPSIS
Connect to a remote Exchange server. Specify -ExchangeOnline to connect Office 365 or specify -ConnectionURI with the https://mail.domain.com/powershell link to the server you want to connect to. You can provide a credential with -Credential or let the function prompt for a credential. You can also specify an alternate session name.

For Exchange Online, you can use delegated adminstration and provide a -Domain to connect to any tenant using your own credentials.
#>
    [cmdletbinding(DefaultParameterSetName = "Exchange")]
    param (
        [Parameter(ParameterSetName = "Exchange")][Alias("Online")][boolean]$ExchangeOnline = $true,
        [Parameter(ParameterSetName = "Exchange")]
        [Parameter(ParameterSetName = "SecurityAndCompliance")][string]$Domain,
        [Parameter(ParameterSetName = "SecurityAndCompliance")][Alias("SACC", "SAC", "SCC")][switch]$SecurityAndComplianceCenter,
        [Parameter(ParameterSetName = "OnPrem")][string]$ConnectionURI,
        [ValidateSet("Default", "Basic", "Kerberos")]$Authentication = "Basic",
        [string]$SessionName = $ExchangeSessionNamePreference,
        [PSCredential]$Credential
    )

    $ExchangeSessionNamePreference = $SessionName

    if ($SecurityAndComplianceCenter.IsPresent) {
        if ($Domain) {
            $ConnectionURI = "https://ps.compliance.protection.outlook.com/powershell-liveid?DelegatedOrg=$Domain"
        }
        else {
            $ConnectionURI = "https://ps.compliance.protection.outlook.com/powershell-liveid"
        }
    }

    if ($ExchangeOnline) {
        if ($Domain) {
            $ConnectionURI = "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$Domain"
        }
        else {
            $ConnectionURI = "https://outlook.office365.com/powershell"
        }
    }

    if ($null -eq $Credential) {
        $Credential = Get-Credential -Message "Specify credentials for $ConnectionURI"
    }

    $ExchangeSession = New-PSSession -Name $SessionName -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionURI -AllowRedirection -Authentication $Authentication -Credential $Credential -ErrorVariable ConnectError
    
    if ($ExchangeSession) {
        Import-Module -ModuleInfo (Import-PSSession -Session $ExchangeSession -DisableNameChecking -AllowClobber) -Global
    }

}