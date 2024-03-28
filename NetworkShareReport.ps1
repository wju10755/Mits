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