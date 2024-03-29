# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Check for temp directory and create if not exist
$tmp = "c:\temp"
if (-not (Test-Path $tmp)) {
    Write-Host "Creating temp directory."
    mkdir c:\temp | Out-Null
}

# Specify the UNC path to the folder
$folderPath = Read-Host -Prompt "Enter UNC path to share"

# Get the folder name
$folderName = Split-Path $folderPath -Leaf

# Get the subfolders
$subfolders = Get-ChildItem -Path $folderPath -Directory

# Create an array to store the results
$results = @()

# For each subfolder, get and output the groups and members
foreach ($subfolder in $subfolders) {
    # Get the ACL for the subfolder
    $acl = Get-Acl -Path $subfolder.FullName

    # Get the unique groups assigned access to the subfolder
    $groups = $acl.Access | Where-Object { $_.IdentityReference -notlike "*\SYSTEM" -and $_.IdentityReference -notlike "*\Administrator" -and $_.IdentityReference -notlike "BUILTIN\Administrators" -and $_.IdentityReference -notlike "CREATOR OWNER" -and $_.IdentityReference -ne "SMCINC\mitsadmin" } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IdentityReference -Unique
    Write-Host " "
    Write-Host "The following groups have permission assigned to the " -NoNewline
    Write-Host -ForegroundColor Yellow $folderName -NoNewline
    Write-Host " share: " -NoNewline
    Write-Host -ForegroundColor Yellow " $($groups -join ', ')"
    Start-Sleep -Seconds 2

    # For each group, get and output the members
    foreach ($group in $groups) {
        # Get the group name
        $groupName = $group.Value.Split('\')[-1]

        try {
            # Get the members of the group and sort them alphabetically
            $members = Get-ADGroupMember -Identity $groupName -ErrorAction Stop | Where-Object { $_.SamAccountName -ne "Administrator" -and $_.SamAccountName -ne "SYSTEM" -and $_.SamAccountName -ne "mitsadmin"} -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName | Sort-Object
        }
        catch {
            Write-Host "Failed to get members for group: " -NoNewline
            Write-Host -ForegroundColor Red $groupName -NoNewline
            Write-Host " (Member possibly disabled)"
            continue
        }
        #Write-Host "Group: $groupName"
        Write-Host "Members:"
        $members
        # Create a custom object for the subfolder
        $result = New-Object PSObject
        $result | Add-Member -Type NoteProperty -Name "FolderName" -Value $subfolder.Name
        $result | Add-Member -Type NoteProperty -Name "GroupName" -Value $groupName
        $result | Add-Member -Type NoteProperty -Name "Members" -Value ($members -join ', ')

        # Add the custom object to the array
        $results += $result
    }
}

# Export the array to a CSV file
$results | Export-Csv -Path "C:\temp\SharePermissions.csv" -NoTypeInformation