function Get-RWMailboxGroupMembership {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [string[]]
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $Identity,
        [string[]]
        [Parameter(Position = 1)]
        $GroupIdentity
    )

    Begin {
        if ($GroupIdentity) {
            $Groups = foreach ($Group in $GroupIdentity) {
                $G = Get-DistributionGroup -Identity $Group
                if (-not $G) {
                    Write-Error -Message "Could not find group '$G'"
                    Continue
                }
                else {
                    $G
                }
            }
            [pscustomobject[]]$GroupMembers = foreach ($Group in $Groups) {
                Write-Verbose -Message "Getting members for group '$($Group.Name)'"
                $Members = Get-DistributionGroupMember -Identity $Group.Name
                [pscustomobject]@{
                    GroupName = $Group.Name
                    Members   = $Members
                }
            }
        }
        else {
            Write-Verbose -Message "Getting all distribution groups"
            $Groups = Get-DistributionGroup
            Write-Verbose -Message "Getting members of all groups"
            [pscustomobject[]]$GroupMembers = foreach ($Group in $Groups) {
                $Members = Get-DistributionGroupMember -Identity $Group.Name
                [pscustomobject]@{
                    GroupName = $Group.Name
                    Members   = $Members
                }
            }
        }
    }
    Process {
        foreach ($User in $Identity) {
            $Mailbox = Get-Mailbox -Identity $User -ErrorAction SilentlyContinue
            if (-not $Mailbox) {
                Write-Error -Message "Could not find mailbox for user '$User'"
                Continue
            }
            Write-Verbose -Message "Found mailbox for '$User'"
            $UserGroups = foreach ($Group in $Groups) {
                foreach ($Member in $GroupMembers.Where( { $_.GroupName -eq $Group.Name }).Members | Where-Object -Property Alias -eq $Mailbox.Alias) {
                    $Group
                    Write-Verbose -Message "Found '$user' in '$($Group.Name)'"
                }
            }
            $OutputObject = [pscustomobject]@{
                UserDisplayName        = $Mailbox.DisplayName
                Mailbox                = $Mailbox
                Groups                 = $UserGroups
            }
            $OutputObject
        }
    }
    End {
    }
}