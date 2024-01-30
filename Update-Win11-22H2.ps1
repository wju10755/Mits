# Update Windows 11 to 22H2
# Author: Bing
# Date: 2024-01-25
# Description: This script uses the Windows Update Agent API to download and install the Windows 11 22H2 update on a device.

# Load the Windows Update Agent API
$WUApi = New-Object -ComObject Microsoft.Update.Session

# Create an update searcher object
$WUSearcher = $WUApi.CreateUpdateSearcher()

# Search for the Windows 11 22H2 update
$WUSearchResult = $WUSearcher.Search("Type='Software' and IsHidden=0 and IsInstalled=0 and Title='Windows 11, version 22H2'")

# Check if the update is available
if ($WUSearchResult.Updates.Count -eq 0) {
    Write-Host "The Windows 11 22H2 update is not available for this device."
    Exit
}

# Get the update object
$WUUpdate = $WUSearchResult.Updates.Item(0)

# Check if the device is compatible with the update
if (-not $WUUpdate.IsDownloaded) {
    Write-Host "Checking the device compatibility with the Windows 11 22H2 update..."
    $WUUpdate.AcceptEula()
    $WUUpdate.Download()
    if ($WUUpdate.InstallationBehavior.CanRequestUserInput -eq $true) {
        Write-Host "The device is not compatible with the Windows 11 22H2 update."
        Exit
    }
}

# Create an update downloader object
$WUDownloader = $WUApi.CreateUpdateDownloader()

# Add the update to the download collection
$WUDownloader.Updates.Add($WUUpdate)

# Download the update
Write-Host "Downloading the Windows 11 22H2 update..."
$WUDownloadResult = $WUDownloader.Download()

# Check the download result
if ($WUDownloadResult.ResultCode -ne 2) {
    Write-Host "The Windows 11 22H2 update download failed with error code $($WUDownloadResult.ResultCode)."
    Exit
}

# Create an update installer object
$WUInstaller = $WUApi.CreateUpdateInstaller()

# Add the update to the install collection
$WUInstaller.Updates.Add($WUUpdate)

# Install the update
Write-Host "Installing the Windows 11 22H2 update..."
$WUInstallResult = $WUInstaller.Install()

# Check the install result
if ($WUInstallResult.ResultCode -ne 2) {
    Write-Host "The Windows 11 22H2 update installation failed with error code $($WUInstallResult.ResultCode)."
    Exit
}

# Restart the device if needed
if ($WUInstallResult.RebootRequired -eq $true) {
    Write-Host "The Windows 11 22H2 update installation completed successfully. A reboot is required to finish the update."
    Restart-Computer -Force
}
else {
    Write-Host "The Windows 11 22H2 update installation completed successfully. No reboot is required."
}
