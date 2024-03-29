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