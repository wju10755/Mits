cls
Write-Host "Checking for required modules..." -NoNewline
# Check and Install NTFSSecurity Module if not found
if (-not (Get-Module -Name 'NTFSSecurity' -ErrorAction SilentlyContinue)) {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module -Name 'NTFSSecurity' -Force 3>$null | Out-Null
    Import-Module -Name 'NTFSSecurity' -WarningAction SilentlyContinue
}
Write-Host " done."

$tmp = "c:\temp"
if (-not (Test-Path $tmp)) {
    Write-Host "Creating temp directory."
    mkdir c:\temp | Out-Null
}
Write-Host " "
# Shared folder path
$sharePath = Read-Host -Prompt "Enter UNC path to share"
Write-Host "Processing share permissions..." -NoNewline
# get all subfolders
$Tree = Get-ChildItem -Path $sharePath -Recurse -Directory
# Get NTFS permission for the root folder
$NTFS = Get-NTFSAccess -Path $sharePath
# Get the NTFS permissions for all sub folders (only explicit permissions, not inherited)
$NTFS += foreach ($dir in $tree)
    {
     Get-NTFSAccess -Path $dir.fullName -ExcludeInherited
    }
Write-Host " done."
Write-Host " "
# In the $NTFS the first line are NTFS perm for the root folder, and after on NTFS perm for subfolders that differ from the root folder
# And now export in the format you would like
Write-Host "Output file location: $csvPath"
$csvPath = "c:\temp\NTFS.csv"
$Ntfs | Export-Csv -Path $csvPath -NoTypeInformation 

# Open the exported CSV file
explorer.exe /select,c:\temp\ntfs.csv
