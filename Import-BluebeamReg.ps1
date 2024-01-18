$url = "https://advancestuff.hostedrmm.com/labtech/transfer/installers/BBDisableUpdate.reg"
$file = "c:\temp\BBDisableUpdate.reg"
$tmp = "C:\temp"

# Create temp directory
if (!(Test-Path $tmp)) {
    New-Item -path $tmp -ItemType Directory -Force
}

# Define the path to the .reg file
$regFilePath = 'c:\temp\BBDisableUpdate.reg'

# Import the .reg file
try {
    regedit /s $regFilePath
    Write-Host "Registry file imported successfully."
} catch {
    Write-Host "Failed to import the registry file. Error: $_"
}