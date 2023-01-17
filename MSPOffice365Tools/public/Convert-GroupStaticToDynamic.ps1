function Convert-GroupStaticToDynamic {
    Param(
        [string]$groupId,
        [string]$dynamicMembershipRule
    )

    $dynamicGroupTypeString = "DynamicMembership"

    #existing group types
    [System.Collections.ArrayList]$groupTypes = (Get-AzureAdMsGroup -Id $groupId).GroupTypes

    if ($null -ne $groupTypes -and $groupTypes.Contains($dynamicGroupTypeString)) {
        throw "This group is already a dynamic group. Aborting conversion."
    }
    #add the dynamic group type to existing types
    $groupTypes.Add($dynamicGroupTypeString)

    #modify the group properties to make it a static group: i) change GroupTypes to add the dynamic type, ii) start execution of the rule, iii) set the rule
    Set-AzureAdMsGroup -Id $groupId -GroupTypes $groupTypes.ToArray() -MembershipRuleProcessingState "On" -MembershipRule $dynamicMembershipRule
}