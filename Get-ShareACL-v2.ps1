# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Specify the path to the folder
$folderPath = "E:\MITS"

# Get the ACL for the folder
$acl = Get-Acl -Path $folderPath

# Get the groups assigned access to the folder
$groups = $acl.Access | Where-Object { $_.IdentityReference -notlike "*\SYSTEM" -and $_.IdentityReference -notlike "*\Administrator" -and $_.IdentityReference -notlike "CREATOR OWNER" } | Select-Object -ExpandProperty IdentityReference

# Output the groups
$groups

# For each group, get and output the members
foreach ($group in $groups) {
    # Get the group name
    $groupName = $group.Value.Split('\')[-1]

    # Get the members of the group
    $members = Get-ADGroupMember -Identity $groupName | Where-Object { $_.SamAccountName -ne "Administrator" -and $_.SamAccountName -ne "SYSTEM"} | Select-Object -ExpandProperty SamAccountName

    # Output the group name and members
    Write-Host "Group: $groupName"
    Write-Host "Members:"
    $members
}