function Get-MoveRequestLargeItems {
    <#
.Synopsis
   Takes MoveRequestStatistics object with -IncludeReport specified. Accepts InputObject from pipeline.
.DESCRIPTION
   Long description
.EXAMPLE
   Get-MoveRequestStatistics -IncludeReport | Get-MoveRequestLargeItems
.EXAMPLE
   Import-Clixml .\RequestStatsReport.xml | Get-MoveRequestLargeItems
#>
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # MoveRequestStatistics Object
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $InputObject
    )

    Begin {
        $properties = "Sender", "Recipient", "FolderName", "Subject", "DateSent", "DateReceived"
        $col = @()
    }
    Process {
        foreach ($user in $InputObject) {   
            if ($null -eq $user.Report) {
                Write-Warning "Report for user '$user' is blank, did you run Get-MoveRequestStatistics with -IncludeReport?"
            }
            foreach ($item in $user.Report.LargeItems) {
                $obj1 = New-Object psobject
                Add-Member -InputObject $obj1 -MemberType NoteProperty -Name DisplayName -Value $user.Identity
                foreach ($prop in $properties) {
                    Add-Member -InputObject $obj1 -MemberType NoteProperty -Name $prop -Value $item.$prop
                }
                Add-Member -InputObject $obj1 -MemberType NoteProperty -Name "MessageSizeMB" -Value ([int]($item.MessageSize / 1MB))
                $col += $obj1
            }
        }
    }
    End {
        $col
    }
}