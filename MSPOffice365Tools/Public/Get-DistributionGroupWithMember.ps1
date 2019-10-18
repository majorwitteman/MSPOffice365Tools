function Get-DistributionGroupWithMember {
    [CmdletBinding()]
    param (
        # Group Object from Get-DistribuionGroup
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("Object")]
        $GroupObject
    )
    
    begin {
        if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.ComputerName -eq 'outlook.office365.com' } )) {
            Write-Warning "Please connect to Exchange Online to convert distribution groups from AD synchronized to cloud-only; exiting script"
            Exit
        }
    }
    
    process {
        foreach($group in $GroupObject) {
            $member = Get-DistributionGroupMember -Identity $group.ExternalDirectoryObjectId
            [pscustomobject]@{
                Group = $group
                Member = $member
            }
        }
    }
    
    end {
        
    }
}