# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Specify the UNC path to the folder
$folderPath = "\\SMC-FS01\Departments\Estimating"

# Get the folder name
$folderName = Split-Path $folderPath -Leaf

# Get the ACL for the folder
$acl = Get-Acl -Path $folderPath

# Get the unique groups assigned access to the folder
$groups = $acl.Access | Where-Object { $_.IdentityReference -notlike "*\SYSTEM" -and $_.IdentityReference -notlike "*\Administrator" -and $_.IdentityReference -notlike "BUILTIN\Administrators" -and $_.IdentityReference -notlike "CREATOR OWNER" -and $_.IdentityReference -ne "SMCINC\mitsadmin" } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IdentityReference -Unique
# Output the groups on the same line separated by a comma and a space
Write-Host " "
Write-Host "The following groups have access to the folder: $($groups -join ', ')"
Write-Host " "
#Write-Host $folderName
# Output the folder name
#Write-Host "Folder: $folderName`n"

# For each group, get and output the members
foreach ($group in $groups) {
    # Get the group name
    $groupName = $group.Value.Split('\')[-1]

    # Get the members of the group
    $members = Get-ADGroupMember -Identity $groupName | Where-Object { $_.SamAccountName -ne "Administrator" -and $_.SamAccountName -ne "SYSTEM" -and $_.SamAccountName -ne "mitsadmin"} -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName

    # Output the group name and members
    Write-Host "Group: $groupName"
    Write-Host "Members:"
    $members
    Write-Host "`n"
}