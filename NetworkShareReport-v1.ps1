[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
clear-host
function Print-Middle( $Message, $Color = "White" )
{
    Write-Host ( " " * [System.Math]::Floor( ( [System.Console]::BufferWidth / 2 ) - ( $Message.Length / 2 ) ) ) -NoNewline;
    Write-Host -ForegroundColor $Color $Message;
}
# Print Script Title
#################################
$Padding = ("=" * [System.Console]::BufferWidth);
Write-Host -ForegroundColor "Red" $Padding -NoNewline;
Print-Middle "MITS - Shared Folder Permissions Report"
Write-Host -ForegroundColor DarkRed "                                                      version 0.0.1";

Write-Host -ForegroundColor "Red" $Padding;
Write-Host `n

# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Check for temp directory and create if not exist
$tmp = "c:\temp"
if (-not (Test-Path $tmp)) {
    Write-Host "Creating temp directory."
    mkdir c:\temp | Out-Null
}

# Specify the UNC path to the folder
Write-Host -ForegroundColor Cyan "Enter UNC path to share " -NoNewline
$folderPath = Read-Host

# Get the folder name
$folderName = $folderPath -split '\\' | Select-Object -Last 1

# Get the subfolders
$subfolders = Get-ChildItem -Path $folderPath -Directory

# Create an array to store the results
$results = @()

# Output the folder name
Write-Host " "
Write-Host "UNC Path: " -NoNewline
Write-Host -ForegroundColor Yellow $folderPath
Write-Host "Processing subfolder: " -NoNewline
Write-Host -ForegroundColor Yellow $folderName
Start-Sleep -Seconds 1

# For each subfolder, get and output the groups and members
foreach ($subfolder in $subfolders) {
    # Get the ACL for the subfolder
    $acl = Get-Acl -Path $subfolder.FullName

    # Get the unique groups assigned access to the subfolder
    $groups = $acl.Access | Where-Object { $_.IdentityReference -notlike "*\SYSTEM" -and $_.IdentityReference -notlike "*\Administrator" -and $_.IdentityReference -notlike "BUILTIN\Administrators" -and $_.IdentityReference -notlike "CREATOR OWNER" -and $_.IdentityReference -ne "SMCINC\mitsadmin" -and $_.IdentityReference -ne "BUILTIN\Everyone" -and $_.IdentityReference -notmatch 'S-\d-\d+-(\d+-){1,14}\d+' } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IdentityReference -Unique
    Write-Host " "
    Write-Host " "
    Write-Host "The following groups/members have permission to the subfolder " -NoNewline
    Write-Host -ForegroundColor Yellow $subfolder.Name -NoNewline
    Write-Host ": " -NoNewline
    Write-Host -ForegroundColor Yellow " $($groups -join ', ')"
    
    # For each group, get and output the members
    foreach ($group in $groups) {
        # Get the group name
        $groupName = $group.Value.Split('\')[-1]

        try {
            # Get the members of the group and sort them alphabetically
            $members = Get-ADGroupMember -Identity $groupName -ErrorAction Stop | Where-Object { $_.SamAccountName -ne "Administrator" -and $_.SamAccountName -ne "SYSTEM" -and $_.SamAccountName -ne "mitsadmin" -and $_.SamAccountName -ne "Everyone"} -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName | Sort-Object
        }
        catch {
            continue
        }
        #Write-Host " "
        Write-Host -ForegroundColor Yellow $groupname -NoNewline
        Write-Host " Group Members:"
        if ($members -eq $null -or $members -eq '') {
            $members = "No group members assigned"
        }
        $members
        Write-Host " "
        if ($members -eq " ---No members assigned to this group--- ") {
            #Write-Host " "
            Write-Host "Failed to get members for group: " -NoNewline
            Write-Host -ForegroundColor Red $groupName -NoNewline
            Write-Host " (No group members or member is disabled)"
            #Write-Host " "
        }
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


$tmp = "c:\temp"
if (-not (Test-Path $tmp)) {
    Write-Host "Creating temp directory."
    mkdir c:\temp | Out-Null
}

# Get the network share path
$sharePath = Read-Host -Prompt "Enter UNC path to share (\\servername\sharename)"

# Get all of the subfolders in the share
$subfolders = Get-ChildItem -Path $sharePath -Recurse

# Get the permissions for each subfolder
$permissions = @()
foreach ($subfolder in $subfolders) {
    $permissions += Get-Acl -Path $subfolder.FullName
}

# Export the permissions to a CSV file
$permissions | Export-Csv -Path "C:\Temp\share_permissions.csv" -NoTypeInformation