function ConvertDynamicGroupToStatic {
    Param(
        [string]$groupId
    )

    $dynamicGroupTypeString = "DynamicMembership"

    #existing group types
    [System.Collections.ArrayList]$groupTypes = (Get-AzureAdMsGroup -Id $groupId).GroupTypes

    if ($null -ne $groupTypes -or !$groupTypes.Contains($dynamicGroupTypeString)) {
        throw "This group is already a static group. Aborting conversion.";
    }

    #remove the type for dynamic groups, but keep the other type values
    $groupTypes.Remove($dynamicGroupTypeString)

    #modify the group properties to make it a static group: i) change GroupTypes to remove the dynamic type, ii) pause execution of the current rule
    Set-AzureAdMsGroup -Id $groupId -GroupTypes $groupTypes.ToArray() -MembershipRuleProcessingState "Paused"
}